"""Shared math for the recommender: cosine similarity, geo distance, quality."""

from __future__ import annotations

import math

_EARTH_RADIUS_KM = 6371.0


def cosine(a: dict[str, float], b: dict[str, float]) -> float:
    """Cosine similarity between two sparse vectors (dicts of key -> weight)."""
    if not a or not b:
        return 0.0
    # Iterate the smaller vector for the dot product.
    small, large = (a, b) if len(a) <= len(b) else (b, a)
    dot = sum(w * large.get(k, 0.0) for k, w in small.items())
    if dot == 0.0:
        return 0.0
    na = math.sqrt(sum(w * w for w in a.values()))
    nb = math.sqrt(sum(w * w for w in b.values()))
    if na == 0.0 or nb == 0.0:
        return 0.0
    return dot / (na * nb)


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance in km between two lat/lng points."""
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    h = (
        math.sin(dphi / 2) ** 2
        + math.cos(p1) * math.cos(p2) * math.sin(dlambda / 2) ** 2
    )
    return 2 * _EARTH_RADIUS_KM * math.asin(min(1.0, math.sqrt(h)))


def quality_score(avg_rating: float, jobs_completed: int) -> float:
    """Blend the Bayesian rating (0..5) with experience into a 0..1 score."""
    rating = max(0.0, min(avg_rating, 5.0)) / 5.0
    experience = min(jobs_completed, 50) / 50.0
    return round(0.75 * rating + 0.25 * experience, 6)


def proximity_score(distance_km: float) -> float:
    """Distance decays to a 0..1 score; ~1.0 nearby, ~0.5 at 5 km, → 0 far away."""
    return 1.0 / (1.0 + distance_km / 5.0)


def normalize(values: dict[str, float]) -> dict[str, float]:
    """Scale a map of scores into 0..1 by its max (no-op if max <= 0)."""
    if not values:
        return {}
    top = max(values.values())
    if top <= 0:
        return {k: 0.0 for k in values}
    return {k: v / top for k, v in values.items()}
