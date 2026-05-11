from typing import Any, Dict, List

from pydantic import BaseModel, ConfigDict, Field


class UploadResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    boq_json: dict[str, Any] = Field(alias="json")
    csv: str
    table: str
    summary: dict[str, Any]
    pages: list[dict[str, Any]] = Field(default_factory=list)


class BOQItem(BaseModel):
    component: str
    qty: int
    unit_cost: float
    labor_cost: float
    subtotal: float
    labor_total: float
    confidence: float
    ratings: List[str]


class BOQResponse(BaseModel):
    summary: Dict[str, Any]
    cost_breakdown: List[BOQItem]
    pages: List[Any]
    totals: Dict[str, float]
