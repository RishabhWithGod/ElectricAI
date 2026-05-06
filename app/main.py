from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.api import router as api_router
from app.routes.static import router as static_router

app = FastAPI(
    title="Electrical Drawing BOQ Service",
    version="1.0.0",
    description="Upload electrical drawing PDFs and generate BOQ outputs from OCR and vision detections.",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(static_router)
app.include_router(api_router)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=False)
