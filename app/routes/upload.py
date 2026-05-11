import os
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from app.services.pdf_service import pdf_to_images
from app.services.yolo_service import detect_components
from app.services.ocr_service import extract_text
from app.services.rule_engine import process_results
from app.services.cost_engine import calculate_boq_cost
from app.utils.io import save_upload

router = APIRouter(prefix="/api")

@router.post("/upload", response_class=JSONResponse)
async def upload_file(file: UploadFile = File(...)):
    if not file.filename.lower().endswith((".pdf", ".png", ".jpg", ".jpeg")):
        raise HTTPException(status_code=400, detail="Only PDF or image files allowed")
    try:
        path = await save_upload(file)
        images = await pdf_to_images(path)
        if not images:
            raise HTTPException(status_code=400, detail="No images extracted from file")
        detections = await detect_components(images)
        ocr_results = await extract_text(images)
        processed = process_results(detections, ocr_results)
        cost = await calculate_boq_cost(processed)
        response = {
            "summary": processed["summary"],
            "cost_breakdown": cost["cost_breakdown"],
            "pages": processed["items"],
            "totals": {
                "material_total": cost["material_total"],
                "labor_total": cost["labor_total"],
                "grand_total": cost["grand_total"]
            }
        }
        return response
    except Exception as e:
        logging.exception("Processing failed")
        raise HTTPException(status_code=500, detail=str(e))
