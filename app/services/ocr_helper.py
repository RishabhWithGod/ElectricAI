import pytesseract
import cv2
from typing import List, Dict, Any

class OCRHelper:
    @staticmethod
    def extract_text(img) -> List[Dict[str, Any]]:
        data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)
        res = []
        n = len(data['level'])
        for i in range(n):
            text = data['text'][i].strip()
            if not text:
                continue
            x, y, w, h = data['left'][i], data['top'][i], data['width'][i], data['height'][i]
            res.append({"text": text, "box": [x, y, w, h]})
        return res
