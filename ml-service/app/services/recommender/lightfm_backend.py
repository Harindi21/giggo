"""Optional LightFM backend (RECOMMENDER_BACKEND=lightfm).

LightFM is a compiled package that needs a *trained* model, so it is
deliberately not a default dependency (it has no wheels on some Python
versions, and training needs the full interaction history offline). When
enabled and available, a pre-trained model would be loaded and served here.

If LightFM isn't installed, importing this module raises ImportError and the
service falls back to the hybrid recommender — the same seam pattern as the
RoBERTa sentiment backend.
"""

from __future__ import annotations

import lightfm  # noqa: F401  (import guard: raises ImportError when not installed)

from app.schemas.recommendation import RecommendationRequest, RecommendedProvider


class LightFmRecommender:
    version = "lightfm"

    def __init__(self) -> None:
        # A persisted, pre-trained LightFM model + id mappings would be loaded here.
        raise NotImplementedError(
            "LightFM backend is a seam: train and persist a model offline, then "
            "load and serve it here. Until then the hybrid recommender is used."
        )

    def recommend(
        self, req: RecommendationRequest
    ) -> tuple[str, list[RecommendedProvider]]:  # pragma: no cover
        raise NotImplementedError
