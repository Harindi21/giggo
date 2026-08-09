from pydantic import BaseModel, Field


class SentimentRequest(BaseModel):
    text: str = Field(min_length=1, max_length=5000)
    review_id: str | None = None


class SentimentResponse(BaseModel):
    label: str        # positive | neutral | negative
    score: float      # -1.0 (very negative) .. 1.0 (very positive)
    star_rating: int  # 1 .. 5, feeds the enhanced-rating formula
    confidence: float
    emotion: str      # frustration | dissatisfaction | neutral | approval | satisfaction
    language: str     # en | si | mixed
    keywords: list[str] = []
    analyzer_version: str
