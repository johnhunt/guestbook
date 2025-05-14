from fastapi import FastAPI, Response
from pydantic import BaseModel
from alembic import command
from alembic.config import Config

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

from models import GuestbookEntry

import os, logging

# Allow local UI to access the API
from fastapi.middleware.cors import CORSMiddleware



def run_migrations():
    alembic_ini_path = os.path.join(os.path.dirname(__file__), "alembic.ini")
    alembic_cfg = Config(alembic_ini_path)
    alembic_cfg.set_main_option("sqlalchemy.url", os.getenv("DATABASE_URL"))
    command.upgrade(alembic_cfg, "head")


# --- Database setup ---
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

# --- Pydantic schema for request body ---
class GuestbookEntrySchema(BaseModel):
    name: str
    comment: str

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"], # Allow localhost, if this app were real I'd also allow the prod domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Run the alembic migrations on startup
@app.on_event("startup")
async def startup():
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))  # Simple check to test database connectivity
        db.close()
        run_migrations()
    except Exception as e:
        logging.error(f"Database connection failed: {e}")

@app.post("/guestbook", tags=["Guestbook"])
def add_guestbook_entry(entry: GuestbookEntrySchema):
    db = SessionLocal()
    try:
        print(f"Received entry: {entry}")
        new_entry = GuestbookEntry(name=entry.name, comment=entry.comment)
        print("hi3")

        db.add(new_entry)
        db.commit()
        db.refresh(new_entry)
        db.close()

        return {
            "message": "Guestbook entry added",
            "entry": {
                "id": new_entry.id,
                "name": new_entry.name,
                "message": new_entry.comment
            }
        }
    except Exception as e:
        db.rollback()  # Rollback any pending transaction on failure
        logging.error(f"Error adding guestbook entry: {e}")
        print(e)
        raise HTTPException(status_code=500, detail="An error occurred while adding the entry")
    finally:
        db.close()

@app.get("/guestbook", tags=["Guestbook"])
def get_all_guestbook_entries():
    db = SessionLocal()
    entries = db.query(GuestbookEntry).all()
    db.close()
    return {
        "entries": [
            {"id": e.id, "name": e.name, "comment": e.comment, "created_at": e.created_at.isoformat(timespec='milliseconds') + 'Z'}
            for e in entries
        ]
    }