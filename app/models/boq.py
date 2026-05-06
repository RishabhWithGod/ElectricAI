from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class UploadResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    boq_json: dict[str, Any] = Field(alias="json")
    csv: str
    table: str
    summary: dict[str, Any]
    pages: list[dict[str, Any]] = Field(default_factory=list)
