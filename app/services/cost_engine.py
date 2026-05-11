from app.db.cost_db import get_costs
from typing import Dict, Any
import asyncio

async def calculate_boq_cost(processed: Dict[str, Any]) -> Dict[str, Any]:
    summary = processed.get("summary", {})
    items = []
    material_total = 0
    labor_total = 0
    for comp, v in summary.items():
        costs = await get_costs(comp)
        unit_cost = costs.get('unit_cost', 0)
        labor_cost = costs.get('labor_cost', 0)
        qty = v['qty']
        subtotal = unit_cost * qty
        labor = labor_cost * qty
        material_total += subtotal
        labor_total += labor
        items.append({
            "component": comp,
            "qty": qty,
            "unit_cost": unit_cost,
            "labor_cost": labor_cost,
            "subtotal": subtotal,
            "labor_total": labor,
            "confidence": v.get('confidence', 0),
            "ratings": v.get('ratings', [])
        })
    grand_total = material_total + labor_total
    return {
        "cost_breakdown": items,
        "material_total": material_total,
        "labor_total": labor_total,
        "grand_total": grand_total
    }
