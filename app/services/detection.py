from __future__ import annotations

import math
from pathlib import Path
from typing import Any, List, Optional

import cv2
import numpy as np
import yaml

from app.config import DEFAULT_YOLO_WEIGHTS, YOLO_CLASS_CONFIG, YOLO_CONFIDENCE, YOLO_IMAGE_SIZE
from app.utils.normalize import extract_ratings, normalize_component_name

TARGET_COMPONENTS = ("panel", "transformer", "breaker", "switch", "equipment", "wire")


class YOLODetectionService:
    def __init__(
        self,
        weights_candidates: Optional[List[Optional[Path]]] = None,
        class_config_path: Path = YOLO_CLASS_CONFIG,
        confidence: float = YOLO_CONFIDENCE,
        image_size: int = YOLO_IMAGE_SIZE,
    ) -> None:
        self.weights_path = self._select_weights(weights_candidates or DEFAULT_YOLO_WEIGHTS)
        self.model = self._load_model(self.weights_path)
        self.confidence = confidence
        self.image_size = image_size
        self.class_aliases = self._load_aliases(class_config_path)

    def preprocess(self, image: np.ndarray) -> np.ndarray:
        if image.ndim == 2:
            gray = image
        else:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        denoised = cv2.fastNlMeansDenoising(gray, None, 9, 7, 21)
        contrast = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8, 8)).apply(denoised)
        binary = cv2.adaptiveThreshold(
            contrast,
            255,
            cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY,
            31,
            11,
        )
        return binary

    def detect(self, image: np.ndarray, page_number: int, ocr_tokens: list[dict[str, Any]]) -> list[dict[str, Any]]:
        detections = []
        detections.extend(self._run_yolo(image, page_number, ocr_tokens))
        detections.extend(self._detect_text_components(ocr_tokens))
        detections.extend(self._detect_wire_segments(image, page_number))
        return self._deduplicate(detections)

    def _run_yolo(
        self,
        image: np.ndarray,
        page_number: int,
        ocr_tokens: list[dict[str, Any]],
    ) -> list[dict[str, Any]]:
        if self.model is None:
            return []
        model_input = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR) if image.ndim == 2 else image
        results = self.model.predict(
            source=model_input,
            conf=self.confidence,
            imgsz=self.image_size,
            verbose=False,
        )
        detections: list[dict[str, Any]] = []
        for result in results:
            for box in result.boxes:
                label = self.model.names.get(int(box.cls[0]), str(int(box.cls[0])))
                component_type = normalize_component_name(label, self.class_aliases)
                if not component_type:
                    continue
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                detection = {
                    "name": label,
                    "type": component_type,
                    "box": {
                        "x": x1,
                        "y": y1,
                        "width": max(0, x2 - x1),
                        "height": max(0, y2 - y1),
                    },
                    "confidence": round(float(box.conf[0]), 4),
                    "page": page_number,
                    "source": "yolo",
                }
                rating = self._match_rating(detection["box"], ocr_tokens)
                if rating:
                    detection["rating"] = rating
                detections.append(detection)
        return detections

    def _detect_text_components(self, ocr_tokens: list[dict[str, Any]]) -> list[dict[str, Any]]:
        detections: list[dict[str, Any]] = []
        for token in ocr_tokens:
            component_type = normalize_component_name(token["text"], self.class_aliases)
            if not component_type or component_type == "wire":
                continue
            box = self._pad_box(token["box"], 18)
            detection = {
                "name": token["text"],
                "type": component_type,
                "box": box,
                "confidence": round(float(token.get("confidence", 0.0)) / 100.0, 4),
                "page": token["page"],
                "source": "ocr",
            }
            rating = self._match_rating(box, ocr_tokens)
            if rating:
                detection["rating"] = rating
            detections.append(detection)
        return detections

    def _detect_wire_segments(self, image: np.ndarray, page_number: int) -> list[dict[str, Any]]:
        edges = cv2.Canny(image, 75, 200)
        lines = cv2.HoughLinesP(
            edges,
            rho=1,
            theta=np.pi / 180,
            threshold=120,
            minLineLength=max(40, image.shape[1] // 18),
            maxLineGap=16,
        )
        if lines is None:
            return []

        detections: list[dict[str, Any]] = []
        seen: list[tuple[float, float, float]] = []
        for line in lines[:, 0]:
            x1, y1, x2, y2 = map(int, line.tolist())
            length = math.hypot(x2 - x1, y2 - y1)
            if length < max(50, image.shape[1] * 0.06):
                continue
            midpoint = ((x1 + x2) / 2.0, (y1 + y2) / 2.0)
            angle = round(math.degrees(math.atan2(y2 - y1, x2 - x1)) / 10.0) * 10.0
            if any(
                abs(midpoint[0] - sx) < 30 and abs(midpoint[1] - sy) < 30 and abs(angle - sa) <= 10
                for sx, sy, sa in seen
            ):
                continue
            seen.append((midpoint[0], midpoint[1], angle))
            detections.append(
                {
                    "name": "wire_segment",
                    "type": "wire",
                    "box": {
                        "x": min(x1, x2),
                        "y": min(y1, y2),
                        "width": abs(x2 - x1) or 1,
                        "height": abs(y2 - y1) or 1,
                    },
                    "confidence": min(0.99, round(length / max(image.shape[:2]), 4)),
                    "page": page_number,
                    "source": "opencv",
                }
            )
        return detections

    def _deduplicate(self, detections: list[dict[str, Any]]) -> list[dict[str, Any]]:
        ranked = sorted(detections, key=lambda item: (item["page"], item["type"], -item["confidence"]))
        unique: list[dict[str, Any]] = []
        for candidate in ranked:
            duplicate = False
            for existing in unique:
                if candidate["page"] != existing["page"] or candidate["type"] != existing["type"]:
                    continue
                if self._iou(candidate["box"], existing["box"]) >= 0.45:
                    duplicate = True
                    break
                if candidate["source"] == "ocr" and existing["source"] == "ocr":
                    if candidate["name"].strip().lower() == existing["name"].strip().lower():
                        duplicate = True
                        break
            if not duplicate:
                unique.append(candidate)
        return unique

    def _match_rating(self, box: dict[str, int], ocr_tokens: list[dict[str, Any]]) -> Optional[str]:
        search_box = self._pad_box(box, 32)
        candidates: list[str] = []
        for token in ocr_tokens:
            if self._iou(search_box, token["box"]) <= 0 and not self._box_contains(search_box, token["box"]):
                continue
            candidates.extend(extract_ratings(token["text"]))
        return candidates[0] if candidates else None

    @staticmethod
    def _load_aliases(config_path: Path) -> dict[str, list[str]]:
        if not config_path.exists():
            return {}
        with config_path.open("r", encoding="utf-8") as handle:
            payload = yaml.safe_load(handle) or {}
        return payload.get("targets", {})

    @staticmethod
    def _load_model(weights_path: Optional[Path]):
        if not weights_path:
            return None
        from ultralytics import YOLO

        return YOLO(str(weights_path))

    @staticmethod
    def _select_weights(candidates: List[Optional[Path]]) -> Optional[Path]:
        for candidate in candidates:
            if candidate and Path(candidate).exists():
                return Path(candidate)
        return None

    @staticmethod
    def _pad_box(box: dict[str, int], padding: int) -> dict[str, int]:
        return {
            "x": max(0, int(box["x"]) - padding),
            "y": max(0, int(box["y"]) - padding),
            "width": int(box["width"]) + (padding * 2),
            "height": int(box["height"]) + (padding * 2),
        }

    @staticmethod
    def _iou(first: dict[str, int], second: dict[str, int]) -> float:
        left = max(first["x"], second["x"])
        top = max(first["y"], second["y"])
        right = min(first["x"] + first["width"], second["x"] + second["width"])
        bottom = min(first["y"] + first["height"], second["y"] + second["height"])
        if right <= left or bottom <= top:
            return 0.0
        intersection = (right - left) * (bottom - top)
        first_area = max(1, first["width"] * first["height"])
        second_area = max(1, second["width"] * second["height"])
        return intersection / float(first_area + second_area - intersection)

    @staticmethod
    def _box_contains(container: dict[str, int], candidate: dict[str, int]) -> bool:
        return (
            candidate["x"] >= container["x"]
            and candidate["y"] >= container["y"]
            and candidate["x"] + candidate["width"] <= container["x"] + container["width"]
            and candidate["y"] + candidate["height"] <= container["y"] + container["height"]
        )
