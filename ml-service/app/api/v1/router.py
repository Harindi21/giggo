from fastapi import APIRouter

from app.api.v1 import recommendations, sentiment

api_router = APIRouter()
api_router.include_router(sentiment.router)
api_router.include_router(recommendations.router)