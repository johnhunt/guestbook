from fastapi import FastAPI, Response
from pydantic import BaseModel
from alembic import command
from alembic.config import Config
import os

def run_migrations():
    alembic_ini_path = os.path.join(os.path.dirname(__file__), "alembic.ini")
    alembic_cfg = Config(alembic_ini_path)
    alembic_cfg.set_main_option("sqlalchemy.url", os.getenv("DATABASE_URL"))
    command.upgrade(alembic_cfg, "head")

app = FastAPI()

# Run the alembic migrations on startup
@app.on_event("startup")
async def startup():
    run_migrations()

@app.get(
    "/",
    tags=["Status"],
    # include_in_schema=False,
)
def get_healthcheck(response: Response):
    """Get the health status of this service."""
    return {"status": "passed"}
