from fastapi import APIRouter, Depends

from app.core.security import require_api_key
from app.schemas.recommendation import RecommendationRequest, RecommendationResponse
from app.services import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.post("", response_model=RecommendationResponse)
async def get_recommendations(
    payload: RecommendationRequest, _=Depends(require_api_key)
):
    strategy, results = recommendation_service.recommend(payload)
    return RecommendationResponse(
        customer_id=payload.customer_id, strategy=strategy, results=results
    )