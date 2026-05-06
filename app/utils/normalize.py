import re
from typing import Optional

COMPONENT_PATTERNS = {
    "panel": (
        "panel",
        "panelboard",
        "pnl",
        "db",
        "distribution board",
    ),
    "transformer": (
        "transformer",
        "xfmr",
        "tx",
    ),
    "breaker": (
        "breaker",
        "mcb",
        "mccb",
        "cb",
        "acb",
        "vcb",
    ),
    "switch": (
        "switch",
        "isolator",
        "selector switch",
        "disconnect",
        "sw",
    ),
    "equipment": (
        "ahu",
        "vav",
        "equipment",
        "pump",
        "motor",
        "fan",
        "chiller",
        "ups",
        "generator",
    ),
    "wire": (
        "wire",
        "cable",
        "conduit",
        "feeder",
        "busduct",
        "busway",
    ),
}

RATING_PATTERN = re.compile(r"\b\d+(?:\.\d+)?\s?(?:A|AMP|AMPS|V|KV|KVA|W|KW|HP)\b", re.IGNORECASE)


def normalize_component_name(name: str, aliases: Optional[dict[str, list[str]]] = None) -> Optional[str]:
    normalized = _normalize_text(name)
    active_aliases = aliases or COMPONENT_PATTERNS
    for component, patterns in active_aliases.items():
        if any(_normalize_text(pattern) in normalized for pattern in patterns):
            return component
    return None


def extract_ratings(text: str) -> list[str]:
    matches = []
    for match in RATING_PATTERN.findall(text):
        cleaned = re.sub(r"\s+", "", match.upper()).replace("AMPS", "A").replace("AMP", "A")
        matches.append(cleaned)
    return matches


def _normalize_text(value: str) -> str:
    cleaned = re.sub(r"[^a-z0-9]+", " ", value.lower()).strip()
    return f" {cleaned} "
