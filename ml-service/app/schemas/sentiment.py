from pydantic import BaseModel, Field


class SentimentRequest(BaseModel):
    text: str = Field(min_length=1, max_length=5000)
    review_id: str | None = None


class SentimentResponse(BaseModel):
    label: str        # positive | negative | neutral
    score: float      # -1.0 (very negative) .. 1.0 (very positive)
    confidence: float
    analyzer_version: str