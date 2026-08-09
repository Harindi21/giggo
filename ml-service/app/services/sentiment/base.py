"""Shared types and score mappings for sentiment analysis.

Every analyzer returns a :class:`SentimentResult`. The score is a normalised
compound in ``[-1, 1]`` (VADER convention) and everything else is derived from
it, so results are consistent regardless of which backend produced the score.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Protocol, runtime_checkable


@dataclass
class SentimentResult:
    label: str  # positive | neutral | negative
    score: float  # -1.0 .. 1.0
    star_rating: int  # 1 .. 5 (feeds the enhanced-rating formula)
    confidence: float  # 0.0 .. 1.0
    emotion: str  # frustration | dissatisfaction | neutral | approval | satisfaction
    language: str  # en | si | mixed
    keywords: list[str] = field(default_factory=list)
    analyzer_version: str = "unknown"


@runtime_checkable
class SentimentAnalyzer(Protocol):
    version: str

    def analyze(self, text: str) -> SentimentResult: ...


def score_to_label(score: float) -> str:
    if score >= 0.05:
        return "positive"
    if score <= -0.05:
        return "negative"
    return "neutral"


def score_to_stars(score: float) -> int:
    """Map a [-1, 1] compound score to a 1–5 star rating (thesis sentimentToStars)."""
    if score >= 0.6:
        return 5
    if score >= 0.2:
        return 4
    if score > -0.2:
        return 3
    if score > -0.6:
        return 2
    return 1


def score_to_emotion(score: float) -> str:
    if score >= 0.6:
        return "satisfaction"
    if score >= 0.05:
        return "approval"
    if score > -0.05:
        return "neutral"
    if score > -0.6:
        return "dissatisfaction"
    return "frustration"


def confidence_from(score: float, token_count: int) -> float:
    """Confidence blends signal strength with how much text we had to judge."""
    strength = min(abs(score), 1.0)
    length_factor = min(token_count / 20.0, 1.0)
    return round(min(1.0, 0.7 * strength + 0.3 * length_factor), 3)
