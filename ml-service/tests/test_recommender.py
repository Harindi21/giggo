from app.schemas.recommendation import (
    Interaction,
    ProviderFeature,
    RecommendationRequest,
)
from app.services.recommender.hybrid import HybridRecommender

rec = HybridRecommender()


def _candidates():
    return [
        ProviderFeature(
            provider_id="p1",
            category_ids=["plumbing"],
            district="Colombo",
            avg_rating=4.8,
            rating_count=40,
            jobs_completed=30,
            latitude=6.9271,
            longitude=79.8612,
        ),
        ProviderFeature(
            provider_id="p2",
            category_ids=["plumbing"],
            district="Colombo",
            avg_rating=3.2,
            rating_count=5,
            jobs_completed=4,
            latitude=6.90,
            longitude=79.86,
        ),
        ProviderFeature(
            provider_id="p3",
            category_ids=["electrical"],
            district="Kandy",
            avg_rating=4.9,
            rating_count=60,
            jobs_completed=50,
            latitude=7.2906,
            longitude=80.6337,
        ),
    ]


def test_cold_start_ranks_by_quality():
    req = RecommendationRequest(customer_id="new-user", candidates=_candidates())
    strategy, results = rec.recommend(req)
    assert strategy == "cold_start"
    # p3 has the strongest Bayesian rating + experience.
    assert results[0].provider_id == "p3"
    assert results[0].reason == "Highly rated on GIGGO"


def test_empty_candidates_returns_nothing():
    strategy, results = rec.recommend(RecommendationRequest(customer_id="u"))
    assert strategy == "cold_start"
    assert results == []


def test_collaborative_surfaces_co_booked_provider():
    # u1 booked p1 and p3. u2 (target) booked p1. CF should surface p3 for u2.
    interactions = [
        Interaction(customer_id="u1", provider_id="p1", weight=3),
        Interaction(customer_id="u1", provider_id="p3", weight=3),
        Interaction(customer_id="u2", provider_id="p1", weight=3),
    ]
    req = RecommendationRequest(
        customer_id="u2", candidates=_candidates(), interactions=interactions
    )
    strategy, results = rec.recommend(req)
    assert strategy == "hybrid"
    ids = [r.provider_id for r in results]
    # p1 is excluded (already booked); p3 is the co-booked recommendation.
    assert "p1" not in ids
    assert ids[0] == "p3"
    assert results[0].reason == "Popular with customers like you"


def test_excludes_interacted_by_default():
    interactions = [Interaction(customer_id="u2", provider_id="p1", weight=3)]
    req = RecommendationRequest(
        customer_id="u2", candidates=_candidates(), interactions=interactions
    )
    _, results = rec.recommend(req)
    assert "p1" not in [r.provider_id for r in results]


def test_limit_is_respected():
    req = RecommendationRequest(
        customer_id="u", candidates=_candidates(), limit=2
    )
    _, results = rec.recommend(req)
    assert len(results) == 2
