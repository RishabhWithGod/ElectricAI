from pathlib import Path

from fastapi import APIRouter
from fastapi.responses import FileResponse

from app.config import APP_DIR, PROJECT_ROOT

router = APIRouter(tags=["ui"])


@router.get("/", include_in_schema=False)
async def index() -> FileResponse:
    return FileResponse(Path(APP_DIR / "ui" / "index.html"))


@router.get("/favicon.ico", include_in_schema=False)
async def favicon() -> FileResponse:
    return FileResponse(Path(PROJECT_ROOT / "web" / "favicon.png"), media_type="image/png")
