"""English sentiment via VADER (Valence Aware Dictionary for sEntiment Reasoning).

VADER is a lexicon + rule-based analyzer that understands negation ("not bad"),
intensifiers ("very good"), punctuation emphasis and emojis — a large step up
from the thesis's TextBlob, while staying tiny and dependency-light (no model
download, runs on any free tier). The :class:`SentimentAnalyzer` protocol lets a
heavier transformer backend (e.g. cardiffnlp/twitter-roberta) replace it later
without touching callers.
"""

from __future__ import annotations

import re

from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

from .base import (
    SentimentResult,
    confidence_from,
    score_to_emotion,
    score_to_label,
    score_to_stars,
)

_WORD_RE = re.compile(r"[A-Za-z']+")


class VaderAnalyzer:
    version = "vader-3.3.2"

    def __init__(self) -> None:
        self._vader = SentimentIntensityAnalyzer()

    def analyze(self, text: str, language: str = "en") -> SentimentResult:
        scores = self._vader.polarity_scores(text)
        compound = float(scores["compound"])
        tokens = _WORD_RE.findall(text)
        return SentimentResult(
            label=score_to_label(compound),
            score=round(compound, 3),
            star_rating=score_to_stars(compound),
            confidence=confidence_from(compound, len(tokens)),
            emotion=score_to_emotion(compound),
            language=language,
            keywords=self._keywords(tokens),
            analyzer_version=self.version,
        )

    def _keywords(self, tokens: list[str], limit: int = 5) -> list[str]:
        """Salient sentiment-bearing words present in the text (by |valence|)."""
        lexicon = self._vader.lexicon
        scored: list[tuple[float, str]] = []
        seen: set[str] = set()
        for tok in tokens:
            low = tok.lower()
            if low in seen:
                continue
            valence = lexicon.get(low)
            if valence is not None and abs(valence) >= 1.0:
                scored.append((abs(valence), low))
                seen.add(low)
        scored.sort(reverse=True)
        return [word for _, word in scored[:limit]]
