import asyncio
from io import BytesIO

from starlette.datastructures import UploadFile

from app.routes.api import health, upload_pdf
from app.services.processor import Processor


def test_health_endpoint():
    response = asyncio.run(health())
    assert response == {"status": "ok"}


def test_upload_endpoint(monkeypatch):
    async def fake_process(self):
        return {
            "boq": {
                "panel": 1,
                "transformer": 0,
                "breaker": 2,
                "switch": 1,
                "equipment": 1,
                "wire": 3,
                "ratings": {"breaker": {"20A": 2}},
            },
            "summary": {
                "pages_processed": 1,
                "total_components": 8,
                "detected_types": 5,
                "human_readable": "Processed 1 page(s) and identified 8 component(s).",
            },
            "table_rows": [
                {"component": "Panel", "quantity": 1, "ratings": "-"},
                {"component": "Transformer", "quantity": 0, "ratings": "-"},
                {"component": "Breaker", "quantity": 2, "ratings": "20A x 2"},
                {"component": "Switch", "quantity": 1, "ratings": "-"},
                {"component": "Equipment", "quantity": 1, "ratings": "-"},
                {"component": "Wire", "quantity": 3, "ratings": "-"},
            ],
            "table": "Component | Quantity | Ratings",
            "pages": [],
        }

    monkeypatch.setattr(Processor, "process", fake_process)

    upload = UploadFile(
        file=BytesIO(b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF"),
        filename="drawing.pdf",
    )
    payload = asyncio.run(upload_pdf(upload))
    payload = payload.model_dump(by_alias=True) if hasattr(payload, "model_dump") else payload.dict(by_alias=True)
    assert payload["json"]["breaker"] == 2
    assert "component,quantity,ratings" in payload["csv"].lower()
    assert payload["summary"]["pages_processed"] == 1
