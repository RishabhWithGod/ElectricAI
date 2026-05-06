from fastapi import APIRouter, File, HTTPException, UploadFile

from app.models.boq import UploadResponse
from app.services.factory import create_processor
from app.utils.formatters import rows_to_csv
from app.utils.io import save_upload

router = APIRouter(prefix="/api", tags=["analysis"])


@router.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@router.post("/upload", response_model=UploadResponse)
async def upload_pdf(file: UploadFile = File(...)) -> UploadResponse:
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF uploads are supported.")

    stored_path = await save_upload(file)
    result = await create_processor(stored_path).process()
    return UploadResponse(
        boq_json=result["boq"],
        csv=rows_to_csv(result["table_rows"]),
        table=result["table"],
        summary=result["summary"],
        pages=result["pages"],
    )
