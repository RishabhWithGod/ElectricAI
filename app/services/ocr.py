from typing import Any, Optional

import pytesseract

from app.config import TESSERACT_CMD


class OCRService:
    def __init__(self, tesseract_cmd: Optional[str] = TESSERACT_CMD) -> None:
        if tesseract_cmd:
            pytesseract.pytesseract.tesseract_cmd = tesseract_cmd

    def extract_tokens(self, image, page_number: int) -> list[dict[str, Any]]:
        data = pytesseract.image_to_data(
            image,
            config="--oem 3 --psm 11",
            output_type=pytesseract.Output.DICT,
        )
        token_count = len(data["text"])
        tokens: list[dict[str, Any]] = []
        for index in range(token_count):
            raw_text = data["text"][index].strip()
            confidence = self._parse_confidence(data["conf"][index])
            if not raw_text or confidence < 0:
                continue
            tokens.append(
                {
                    "text": raw_text,
                    "box": {
                        "x": int(data["left"][index]),
                        "y": int(data["top"][index]),
                        "width": int(data["width"][index]),
                        "height": int(data["height"][index]),
                    },
                    "confidence": confidence,
                    "page": page_number,
                }
            )
        return tokens

    @staticmethod
    def _parse_confidence(value: Any) -> float:
        try:
            return float(value)
        except (TypeError, ValueError):
            return -1.0
