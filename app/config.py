import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

APP_DIR = PROJECT_ROOT / "app"
DATA_DIR = PROJECT_ROOT / "data"

UPLOAD_DIR = DATA_DIR / "uploads"
MODEL_DIR = PROJECT_ROOT / "models"

YOLO_CLASS_CONFIG = (
    APP_DIR / "services" / "yolo_custom.yaml"
)


def _load_dotenv(env_path: Path) -> None:
    if not env_path.exists():
        return

    for line in env_path.read_text(
        encoding="utf-8"
    ).splitlines():

        stripped = line.strip()

        if (
            not stripped
            or stripped.startswith("#")
            or "=" not in stripped
        ):
            continue

        key, value = stripped.split("=", 1)

        os.environ.setdefault(
            key.strip(),
            value.strip().strip("\"'")
        )


_load_dotenv(PROJECT_ROOT / ".env")


def _project_path(value: str) -> Path:
    path = Path(value)

    return (
        path
        if path.is_absolute()
        else PROJECT_ROOT / path
    )


_env_weights = os.getenv("YOLO_WEIGHTS_PATH")

DEFAULT_YOLO_WEIGHTS = [
    _project_path(_env_weights)
    if _env_weights
    else None,

    MODEL_DIR / "electrical_best.pt",
    MODEL_DIR / "electrical_yolov8.pt",
    PROJECT_ROOT / "yolov8n.pt",
]

# OCR
TESSERACT_CMD = os.getenv(
    "TESSERACT_CMD",
    "tesseract"
)

# SERVER
PORT = int(os.getenv("PORT", "8000"))

# AI PERFORMANCE CONFIG

# balanced quality/performance
PDF_DPI = int(
    os.getenv("PDF_DPI", "220")
)

YOLO_IMAGE_SIZE = int(
    os.getenv("YOLO_IMAGE_SIZE", "1152")
)

YOLO_CONFIDENCE = float(
    os.getenv("YOLO_CONFIDENCE", "0.18")
)
# VERY IMPORTANT
# prevent huge PDF crashes
MAX_PDF_PAGES = int(
    os.getenv("MAX_PDF_PAGES", "5")
)

# prevent RAM spikes
PDF_THREAD_COUNT = int(
    os.getenv("PDF_THREAD_COUNT", "1")
)

UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True
)

MODEL_DIR.mkdir(
    parents=True,
    exist_ok=True
)