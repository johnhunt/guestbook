from fastapi import FastAPI, Response
from pydantic import BaseModel

app = FastAPI()

@app.get(
    "/",
    tags=["Status"],
    # include_in_schema=False,
)
def get_healthcheck(response: Response):
    """Get the health status of this service."""
    return {"status": "passed"}
