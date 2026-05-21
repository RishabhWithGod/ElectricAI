import os
from typing import List
from pdf2image import convert_from_path
from PIL import Image
import tempfile
import asyncio
import cv2
import numpy as np

def is_image_file(path: str) -> bool:
    return path.lower().endswith((".png", ".jpg", ".jpeg"))

def preprocess_pdf_image(img: Image.Image) -> Image.Image:
    arr = np.array(img.convert('RGB'))
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    blur = cv2.GaussianBlur(gray, (3, 3), 0)
    sharp = cv2.addWeighted(gray, 1.5, blur, -0.5, 0)
    _, thresh = cv2.threshold(sharp, 180, 255, cv2.THRESH_BINARY)
    denoised = cv2.fastNlMeansDenoising(thresh, None, 10, 7, 21)
    return Image.fromarray(denoised)

async def pdf_to_images(path: str) -> List[Image.Image]:
    if is_image_file(path):
        img = Image.open(path)
        return [preprocess_pdf_image(img)]
    loop = asyncio.get_event_loop()
    pil_images = await loop.run_in_executor(None, lambda: convert_from_path(path, dpi=300))
    return [preprocess_pdf_image(im) for im in pil_images]