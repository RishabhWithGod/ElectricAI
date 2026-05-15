import asyncio
from typing import List

import cv2
import numpy as np

from pdf2image import convert_from_path
from PIL import Image

from app.config import (
    PDF_DPI,
    MAX_PDF_PAGES,
    PDF_THREAD_COUNT,
)


def is_image_file(path: str) -> bool:
    return path.lower().endswith(
        (".png", ".jpg", ".jpeg")
    )


def preprocess_pdf_image(
    img: Image.Image,
) -> Image.Image:

    # RGB -> numpy
    arr = np.array(img.convert("RGB"))

    # grayscale
    gray = cv2.cvtColor(
        arr,
        cv2.COLOR_RGB2GRAY,
    )

    # better contrast
    clahe = cv2.createCLAHE(
        clipLimit=2.0,
        tileGridSize=(8, 8),
    )

    enhanced = clahe.apply(gray)

    # denoise
    denoised = cv2.fastNlMeansDenoising(
        enhanced,
        None,
        10,
        7,
        21,
    )

    return Image.fromarray(denoised)


async def pdf_to_images(
    path: str,
) -> List[Image.Image]:

    if is_image_file(path):
        img = Image.open(path)

        return [
            preprocess_pdf_image(img)
        ]

    loop = asyncio.get_event_loop()

    pil_images = await loop.run_in_executor(
        None,
        lambda: convert_from_path(
            path,

            dpi=PDF_DPI,

            first_page=1,
            last_page=MAX_PDF_PAGES,

            thread_count=PDF_THREAD_COUNT,

            use_pdftocairo=True,

            grayscale=True,
        ),
    )

    return [
        preprocess_pdf_image(im)
        for im in pil_images
    ]