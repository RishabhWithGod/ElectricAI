from pathlib import Path

from fastapi import APIRouter
from fastapi.responses import FileResponse, Response

from app.config import APP_DIR, PROJECT_ROOT

router = APIRouter(tags=["ui"])


@router.get("/", include_in_schema=False)
async def index() -> FileResponse:
    return FileResponse(Path(APP_DIR / "ui" / "index.html"))


@router.get("/favicon.ico", include_in_schema=False)
async def favicon():
    icon_path = Path(PROJECT_ROOT / "web" / "favicon.png")
    if not icon_path.exists():
        return Response(status_code=204)
    return FileResponse(icon_path, media_type="image/png")
