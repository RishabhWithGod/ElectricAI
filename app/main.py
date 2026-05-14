import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import PORT
from app.routes.api import router as api_router
from app.routes.static import router as static_router

logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title="Electrical Drawing BOQ Service",
    version="1.0.0",
    description="Upload electrical drawing PDFs and generate BOQ outputs from OCR and vision detections.",
)

# CORS FIX
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
app.include_router(static_router)
app.include_router(api_router)

# Local + Railway Run
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=PORT,
        reload=False,
    )