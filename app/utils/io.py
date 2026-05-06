from pathlib import Path
from uuid import uuid4

import aiofiles
from fastapi import UploadFile

from app.config import UPLOAD_DIR


async def save_upload(file: UploadFile) -> str:
    extension = Path(file.filename or "upload.pdf").suffix or ".pdf"
    destination = UPLOAD_DIR / f"{uuid4().hex}{extension.lower()}"
    async with aiofiles.open(destination, "wb") as handle:
        while True:
            chunk = await file.read(1024 * 1024)
            if not chunk:
                break
            await handle.write(chunk)
    await file.close()
    return str(destination)
