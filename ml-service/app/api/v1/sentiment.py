from fastapi import APIRouter, Depends

from app.core.security import require_api_key
from app.schemas.sentiment import SentimentRequest, SentimentResponse
from app.services import sentiment_service

router = APIRouter(prefix="/sentiment", tags=["sentiment"])


@router.post("", response_model=SentimentResponse)
async def analyse_sentiment(payload: SentimentRequest, _=Depends(require_api_key)):
    label, score, confidence = sentiment_service.analyse(payload.text)
    return SentimentResponse(
        label=label,
        score=score,
        confidence=confidence,
        analyzer_version=sentiment_service.VERSION,
    )