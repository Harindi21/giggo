from fastapi import APIRouter, Depends

from app.core.security import require_api_key
from app.schemas.sentiment import SentimentRequest, SentimentResponse
from app.services.sentiment import get_service

router = APIRouter(prefix="/sentiment", tags=["sentiment"])


@router.post("", response_model=SentimentResponse)
async def analyse_sentiment(payload: SentimentRequest, _=Depends(require_api_key)):
    result = get_service().analyze(payload.text)
    return SentimentResponse(
        label=result.label,
        score=result.score,
        star_rating=result.star_rating,
        confidence=result.confidence,
        emotion=result.emotion,
        language=result.language,
        keywords=result.keywords,
        analyzer_version=result.analyzer_version,
    )
