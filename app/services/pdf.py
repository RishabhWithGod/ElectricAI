from pathlib import Path

import cv2
import numpy as np
from pdf2image import convert_from_path

from app.config import PDF_DPI


class PDFService:
    def __init__(self, dpi: int = PDF_DPI) -> None:
        self.dpi = dpi

    def render_pages(self, pdf_path: str) -> list[np.ndarray]:
        source = Path(pdf_path)
        if not source.exists():
            raise FileNotFoundError(f"PDF not found: {source}")
        pages = convert_from_path(str(source), dpi=self.dpi, fmt="png", thread_count=2)
        return [cv2.cvtColor(np.array(page), cv2.COLOR_RGB2BGR) for page in pages]
