import csv
import io
from typing import Any, Dict, List, Union


Row = Dict[str, Union[str, int]]


def build_boq_rows(boq: dict[str, Any], component_order: tuple[str, ...]) -> List[Row]:
    rows: List[Row] = []
    ratings = boq.get("ratings", {})
    for component in component_order:
        quantity = int(boq.get(component, 0))
        component_ratings = ratings.get(component, {})
        rows.append(
            {
                "component": component.replace("_", " ").title(),
                "quantity": quantity,
                "ratings": ", ".join(f"{rating} x {count}" for rating, count in sorted(component_ratings.items()))
                or "-",
            }
        )
    return rows


def rows_to_csv(rows: List[Row]) -> str:
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=["component", "quantity", "ratings"])
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue()


def rows_to_table(rows: List[Row]) -> str:
    headers = ("Component", "Quantity", "Ratings")
    widths = [
        max(len(headers[0]), *(len(str(row["component"])) for row in rows)),
        max(len(headers[1]), *(len(str(row["quantity"])) for row in rows)),
        max(len(headers[2]), *(len(str(row["ratings"])) for row in rows)),
    ]
    lines = [
        f"{headers[0]:<{widths[0]}} | {headers[1]:<{widths[1]}} | {headers[2]:<{widths[2]}}",
        f"{'-' * widths[0]}-+-{'-' * widths[1]}-+-{'-' * widths[2]}",
    ]
    for row in rows:
        lines.append(
            f"{str(row['component']):<{widths[0]}} | "
            f"{str(row['quantity']):<{widths[1]}} | "
            f"{str(row['ratings']):<{widths[2]}}"
        )
    return "\n".join(lines)
