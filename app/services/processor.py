import asyncio
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Optional

from app.services.detection import TARGET_COMPONENTS, YOLODetectionService
from app.services.ocr import OCRService
from app.services.pdf import PDFService
from app.utils.formatters import build_boq_rows, rows_to_table


class Processor:
    def __init__(
        self,
        pdf_path: str,
        pdf_service: Optional[PDFService] = None,
        ocr_service: Optional[OCRService] = None,
        detection_service: Optional[YOLODetectionService] = None,
        max_concurrency: int = 2,
    ) -> None:
        self.pdf_path = str(Path(pdf_path))
        self.pdf_service = pdf_service or PDFService()
        self.ocr_service = ocr_service or OCRService()
        self.detection_service = detection_service or YOLODetectionService()
        self.max_concurrency = max(1, max_concurrency)

    async def process(self) -> dict[str, Any]:
        pages = await asyncio.to_thread(self.pdf_service.render_pages, self.pdf_path)
        semaphore = asyncio.Semaphore(self.max_concurrency)
        page_results = await asyncio.gather(
            *[self._process_page(index, image, semaphore) for index, image in enumerate(pages, start=1)]
        )
        return self._build_output(page_results)

    async def _process_page(self, page_number: int, image, semaphore: asyncio.Semaphore) -> dict[str, Any]:
        async with semaphore:
            enhanced = await asyncio.to_thread(self.detection_service.preprocess, image)
            ocr_tokens = await asyncio.to_thread(self.ocr_service.extract_tokens, enhanced, page_number)
            detections = await asyncio.to_thread(
                self.detection_service.detect,
                enhanced,
                page_number,
                ocr_tokens,
            )
        return {
            "page_number": page_number,
            "ocr_tokens": ocr_tokens,
            "detections": detections,
        }

    def _build_output(self, page_results: list[dict[str, Any]]) -> dict[str, Any]:
        counts = Counter()
        ratings_by_type: dict[str, Counter[str]] = defaultdict(Counter)

        for page in page_results:
            for detection in page["detections"]:
                component_type = detection["type"]
                counts[component_type] += 1
                rating = detection.get("rating")
                if rating:
                    ratings_by_type[component_type][rating] += 1

        boq = {component: counts.get(component, 0) for component in TARGET_COMPONENTS}
        boq["ratings"] = {
            component: dict(sorted(component_ratings.items()))
            for component, component_ratings in sorted(ratings_by_type.items())
            if component_ratings
        }

        table_rows = build_boq_rows(boq, TARGET_COMPONENTS)
        total_components = sum(counts.values())
        summary = {
            "pages_processed": len(page_results),
            "total_components": total_components,
            "detected_types": sum(1 for component in TARGET_COMPONENTS if counts.get(component, 0)),
            "human_readable": self._build_human_summary(boq, total_components, len(page_results)),
        }
        return {
            "boq": boq,
            "summary": summary,
            "table_rows": table_rows,
            "table": rows_to_table(table_rows),
            "pages": page_results,
        }

    @staticmethod
    def _build_human_summary(boq: dict[str, Any], total_components: int, page_count: int) -> str:
        parts = [
            f"{component.replace('_', ' ')}: {boq[component]}"
            for component in TARGET_COMPONENTS
            if boq.get(component, 0)
        ]
        if not parts:
            parts.append("no supported components detected")
        return (
            f"Processed {page_count} page(s) and identified {total_components} component(s): "
            + ", ".join(parts)
            + "."
        )
