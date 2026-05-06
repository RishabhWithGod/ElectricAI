import os
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
APP_DIR = PROJECT_ROOT / "app"
DATA_DIR = PROJECT_ROOT / "data"
UPLOAD_DIR = DATA_DIR / "uploads"
MODEL_DIR = PROJECT_ROOT / "models"
YOLO_CLASS_CONFIG = APP_DIR / "services" / "yolo_custom.yaml"


def _load_dotenv(env_path: Path) -> None:
    if not env_path.exists():
        return
    for line in env_path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip("\"'"))


_load_dotenv(PROJECT_ROOT / ".env")

_env_weights = os.getenv("YOLO_WEIGHTS_PATH")
DEFAULT_YOLO_WEIGHTS = [
    Path(_env_weights) if _env_weights else None,
    MODEL_DIR / "electrical_yolov8.pt",
    PROJECT_ROOT / "yolov8n.pt",
]

TESSERACT_CMD = os.getenv("TESSERACT_CMD")
PDF_DPI = int(os.getenv("PDF_DPI", "300"))
YOLO_IMAGE_SIZE = int(os.getenv("YOLO_IMAGE_SIZE", "1280"))
YOLO_CONFIDENCE = float(os.getenv("YOLO_CONFIDENCE", "0.20"))

UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
MODEL_DIR.mkdir(parents=True, exist_ok=True)
