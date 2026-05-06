from __future__ import annotations

from functools import lru_cache


@lru_cache(maxsize=1)
def get_pdf_service():
    from app.services.pdf import PDFService

    return PDFService()


@lru_cache(maxsize=1)
def get_ocr_service():
    from app.services.ocr import OCRService

    return OCRService()


@lru_cache(maxsize=1)
def get_detection_service():
    from app.services.detection import YOLODetectionService

    return YOLODetectionService()


def create_processor(pdf_path: str):
    from app.services.processor import Processor

    return Processor(
        pdf_path,
        pdf_service=get_pdf_service(),
        ocr_service=get_ocr_service(),
        detection_service=get_detection_service(),
    )
