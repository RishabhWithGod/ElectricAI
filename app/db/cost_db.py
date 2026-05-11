import aiosqlite
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "costs.db")

async def get_costs(component: str) -> dict:
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT unit_cost, labor_cost, unit FROM materials WHERE item_type = ?", (component,)) as cursor:
            row = await cursor.fetchone()
            if row:
                return {"unit_cost": float(row[0]), "labor_cost": float(row[1]), "unit": row[2]}
    return {"unit_cost": 0.0, "labor_cost": 0.0, "unit": ""}

def init_db():
    import sqlite3
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("""
    CREATE TABLE IF NOT EXISTS materials (
        item_type TEXT PRIMARY KEY,
        unit_cost REAL NOT NULL,
        labor_cost REAL NOT NULL,
        unit TEXT NOT NULL
    )
    """)
    c.executemany("INSERT OR IGNORE INTO materials (item_type, unit_cost, labor_cost, unit) VALUES (?, ?, ?, ?)", [
        ("panel", 5000, 800, "each"),
        ("transformer", 20000, 2500, "each"),
        ("breaker", 300, 50, "each"),
        ("switch", 100, 20, "each"),
        ("equipment", 1500, 200, "each"),
        ("wire", 10, 2, "meter"),
        ("conduit", 15, 3, "meter"),
        ("socket", 50, 10, "each"),
        ("light", 80, 15, "each"),
        ("AHU", 10000, 1200, "each"),
        ("VAV", 7000, 900, "each"),
    ])
    conn.commit()
    conn.close()
