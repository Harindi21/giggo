from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: ML models will be loaded here in P6.
    yield
    # Shutdown: release resources here.


app = FastAPI(title=settings.app_name, version="0.1.0", lifespan=lifespan)

app.include_router(api_router, prefix="/api/v1")


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "environment": settings.environment}