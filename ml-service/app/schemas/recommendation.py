from pydantic import BaseModel, Field


class RecommendationRequest(BaseModel):
    customer_id: str
    service_category: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    limit: int = Field(default=10, ge=1, le=50)


class RecommendedProvider(BaseModel):
    provider_id: str
    score: float
    reason: str


class RecommendationResponse(BaseModel):
    customer_id: str
    strategy: str      # cold_start | collaborative | hybrid
    results: list[RecommendedProvider]