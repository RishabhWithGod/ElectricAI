import asyncio
from typing import List, Any, Dict
from PIL import Image
import pytesseract
import cv2
import numpy as np
from app.utils.normalize import extract_ratings, _normalize_text

def _ocr(img: Image.Image) -> List[Dict]:
    arr = np.array(img.convert('RGB'))
    h, w = arr.shape[:2]
    # Use OpenCV to find contours for region-based OCR
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    _, thresh = cv2.threshold(gray, 180, 255, cv2.THRESH_BINARY_INV)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    results = []
    for cnt in contours:
        x, y, bw, bh = cv2.boundingRect(cnt)
        if bw < 30 or bh < 15:
            continue
        roi = arr[y:y+bh, x:x+bw]
        roi_pil = Image.fromarray(roi)
        text = pytesseract.image_to_string(roi_pil, config='--psm 6')
        text = text.strip()
        if text:
            ratings = extract_ratings(text)
            results.append({"text": text, "box": [x, y, bw, bh], "ratings": ratings, "norm": _normalize_text(text)})
    return results

async def extract_text(images: List[Image.Image]) -> List[List[Dict]]:
    loop = asyncio.get_event_loop()
    return await asyncio.gather(*[loop.run_in_executor(None, _ocr, img) for img in images])
