import asyncio
from typing import List, Any, Dict
from PIL import Image
import numpy as np
from ultralytics import YOLO
import cv2

YOLO_MODEL_PATH = 'models/electrical_best.pt'
YOLO_CLASSES = [
    'switch', 'breaker', 'panel', 'socket', 'transformer',
    'wire', 'conduit', 'light', 'AHU', 'VAV'
]
CONFIDENCE_THRESHOLD = 0.45
IOU_THRESHOLD = 0.3

model = YOLO(YOLO_MODEL_PATH)


def preprocess_image(img: Image.Image) -> np.ndarray:
    arr = np.array(img.convert('RGB'))
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    blur = cv2.GaussianBlur(gray, (3, 3), 0)
    sharp = cv2.addWeighted(gray, 1.5, blur, -0.5, 0)
    _, thresh = cv2.threshold(sharp, 180, 255, cv2.THRESH_BINARY)
    denoised = cv2.fastNlMeansDenoising(thresh, None, 10, 7, 21)
    return cv2.cvtColor(denoised, cv2.COLOR_GRAY2RGB)


def nms(detections: List[Dict], iou_thresh: float = IOU_THRESHOLD) -> List[Dict]:
    # Non-maximum suppression for duplicate removal
    if not detections:
        return []
    boxes = np.array([d['box'] for d in detections])
    scores = np.array([d['conf'] for d in detections])
    idxs = cv2.dnn.NMSBoxes(boxes.tolist(), scores.tolist(), CONFIDENCE_THRESHOLD, iou_thresh)
    idxs = idxs.flatten() if len(idxs) else []
    return [detections[i] for i in idxs]


async def detect_components(images: List[Image.Image]) -> List[List[Dict]]:
    loop = asyncio.get_event_loop()
    results = []
    for img in images:
        pre = preprocess_image(img)
        dets = await loop.run_in_executor(None, lambda: model.predict(pre, imgsz=1024, conf=CONFIDENCE_THRESHOLD))
        page_detections = []
        for r in dets:
            for box in r.boxes:
                cls = int(box.cls[0])
                name = model.names.get(cls, str(cls))
                if name not in YOLO_CLASSES:
                    continue
                conf = float(box.conf[0])
                if conf < CONFIDENCE_THRESHOLD:
                    continue
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                page_detections.append({
                    "class": name,
                    "conf": conf,
                    "box": [x1, y1, x2-x1, y2-y1]
                })
        # Remove duplicates
        filtered = nms(page_detections)
        results.append(filtered)
    return results
