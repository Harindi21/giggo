"""Thin entry point kept for the API import path; delegates to the recommender."""

from app.schemas.recommendation import RecommendationRequest, RecommendedProvider
from app.services.recommender.service import recommend as _recommend


def recommend(
    req: RecommendationRequest,
) -> tuple[str, list[RecommendedProvider]]:
    return _recommend(req)
