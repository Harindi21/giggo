from app.schemas.recommendation import RecommendationRequest, RecommendedProvider


def recommend(req: RecommendationRequest) -> tuple[str, list[RecommendedProvider]]:
    """Placeholder. LightFM hybrid model arrives in P6."""
    results = [
        RecommendedProvider(
            provider_id=f"stub-provider-{i}",
            score=round(1.0 - (i * 0.1), 2),
            reason="stub result — model not trained yet",
        )
        for i in range(1, min(req.limit, 5) + 1)
    ]
    return "cold_start", results