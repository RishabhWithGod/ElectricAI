# Electrical Drawing BOQ Service

FastAPI service for electrical drawing BOQ extraction with PDF upload, OpenCV preprocessing, Tesseract OCR, YOLOv8 detection, BOQ normalization, CSV export, and a lightweight upload UI.

## Project Structure

```text
app/
  models/
  routes/
  services/
  tests/
  ui/
  utils/
data/
models/
```

## Setup

1. Create and activate a virtual environment.
2. Install Python dependencies:

```bash
pip install -r requirements.txt
```

3. Install system binaries:
   - `tesseract`
   - `poppler` with `pdftoppm`

4. Optional environment variables:

```bash
export YOLO_WEIGHTS_PATH=/absolute/path/to/electrical_yolov8.pt
export TESSERACT_CMD=/absolute/path/to/tesseract
```

If `YOLO_WEIGHTS_PATH` is not set, the service checks `models/electrical_yolov8.pt` and then `yolov8n.pt`.

## Run

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Open `http://127.0.0.1:8000`.

## Test

```bash
pytest app/tests -q
```

## API

- `GET /api/health`
- `POST /api/upload`

`POST /api/upload` returns:

- `json`: BOQ JSON payload
- `csv`: CSV export
- `table`: human-readable table
- `summary`: processing summary
- `pages`: per-page OCR and detection data
