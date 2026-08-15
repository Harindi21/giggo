from pydantic import BaseModel, Field


class ProviderFeature(BaseModel):
    """A candidate provider to rank, with the features used for scoring."""

    provider_id: str
    category_ids: list[str] = Field(default_factory=list)
    district: str | None = None
    avg_rating: float = 0.0          # Bayesian composite (0..5), computed upstream
    rating_count: int = 0
    jobs_completed: int = 0
    latitude: float | None = None
    longitude: float | None = None


class Interaction(BaseModel):
    """One customer↔provider signal (e.g. a booking), keyed by provider profile id."""

    customer_id: str
    provider_id: str
    weight: float = 1.0


class RecommendationRequest(BaseModel):
    customer_id: str
    limit: int = Field(default=10, ge=1, le=50)
    latitude: float | None = None
    longitude: float | None = None
    candidates: list[ProviderFeature] = Field(default_factory=list)
    interactions: list[Interaction] = Field(default_factory=list)
    exclude_interacted: bool = True


class RecommendedProvider(BaseModel):
    provider_id: str
    score: float
    reason: str


class RecommendationResponse(BaseModel):
    customer_id: str
    strategy: str      # cold_start | content | collaborative | hybrid
    results: list[RecommendedProvider]
