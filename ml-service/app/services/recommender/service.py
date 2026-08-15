"""Selects the recommender backend (hybrid by default; LightFM when enabled)."""

from __future__ import annotations

import logging

from app.core.config import settings
from app.schemas.recommendation import RecommendationRequest, RecommendedProvider

from .hybrid import HybridRecommender

logger = logging.getLogger(__name__)

_recommender = None


def _build():
    backend = getattr(settings, "recommender_backend", "hybrid")
    if backend == "lightfm":
        try:
            from .lightfm_backend import LightFmRecommender

            return LightFmRecommender()
        except Exception as exc:  # not installed / no trained model
            logger.warning(
                "LightFM backend unavailable (%s); using hybrid recommender.", exc
            )
    return HybridRecommender()


def get_recommender():
    global _recommender
    if _recommender is None:
        _recommender = _build()
    return _recommender


def recommend(
    req: RecommendationRequest,
) -> tuple[str, list[RecommendedProvider]]:
    return get_recommender().recommend(req)
