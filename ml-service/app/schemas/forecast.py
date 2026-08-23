from pydantic import BaseModel, Field


class ForecastRequest(BaseModel):
    """A single demand series (e.g. weekly booking counts) to project forward."""

    series: list[float] = Field(default_factory=list)
    horizon: int = 1


class ForecastResponse(BaseModel):
    forecast: list[float]
    trend: str  # rising | falling | steady
    method: str
