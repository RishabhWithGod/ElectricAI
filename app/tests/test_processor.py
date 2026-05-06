import asyncio

import numpy as np
from PIL import Image

from app.services.detection import YOLODetectionService
from app.services.ocr import OCRService
from app.services.pdf import PDFService
from app.services.processor import Processor


def test_processor_generates_boq(monkeypatch, tmp_path):
    pdf_path = tmp_path / "sample.pdf"
    Image.new("RGB", (200, 200), color="white").save(pdf_path, "PDF")

    def fake_render_pages(self, path):
        return [np.zeros((300, 300, 3), dtype=np.uint8)]

    def fake_extract_tokens(self, image, page_number):
        return [
            {
                "text": "Panel L",
                "box": {"x": 10, "y": 10, "width": 80, "height": 20},
                "confidence": 96.0,
                "page": page_number,
            },
            {
                "text": "20A",
                "box": {"x": 15, "y": 35, "width": 40, "height": 15},
                "confidence": 94.0,
                "page": page_number,
            },
            {
                "text": "XFMR",
                "box": {"x": 120, "y": 15, "width": 50, "height": 20},
                "confidence": 93.0,
                "page": page_number,
            },
            {
                "text": "50KVA",
                "box": {"x": 125, "y": 40, "width": 50, "height": 18},
                "confidence": 92.0,
                "page": page_number,
            },
        ]

    def fake_detect(self, image, page_number, ocr_tokens):
        return [
            {
                "name": "Panel L",
                "type": "panel",
                "box": {"x": 8, "y": 8, "width": 90, "height": 55},
                "confidence": 0.98,
                "page": page_number,
                "source": "ocr",
                "rating": "20A",
            },
            {
                "name": "XFMR",
                "type": "transformer",
                "box": {"x": 118, "y": 10, "width": 70, "height": 60},
                "confidence": 0.95,
                "page": page_number,
                "source": "ocr",
                "rating": "50KVA",
            },
            {
                "name": "wire_segment",
                "type": "wire",
                "box": {"x": 20, "y": 150, "width": 180, "height": 2},
                "confidence": 0.88,
                "page": page_number,
                "source": "opencv",
            },
        ]

    monkeypatch.setattr(PDFService, "render_pages", fake_render_pages)
    monkeypatch.setattr(OCRService, "extract_tokens", fake_extract_tokens)
    monkeypatch.setattr(YOLODetectionService, "detect", fake_detect)

    result = asyncio.run(Processor(str(pdf_path)).process())

    assert result["boq"]["panel"] == 1
    assert result["boq"]["transformer"] == 1
    assert result["boq"]["wire"] == 1
    assert result["boq"]["ratings"]["panel"] == {"20A": 1}
    assert result["boq"]["ratings"]["transformer"] == {"50KVA": 1}
    assert result["summary"]["pages_processed"] == 1
    assert "Panel" in result["table"]
