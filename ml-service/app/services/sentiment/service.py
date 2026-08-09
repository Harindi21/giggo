"""Routes each review to the right analyzer based on its script/keywords.

- Mostly Sinhala script            -> Sinhala keyword analyzer.
- Contains Sinhala/Singlish words  -> blend (VADER on the English parts +
                                      keyword analyzer for Sinhala/romanised words).
- Plain English                    -> VADER lexicon analyzer.

Routing checks the keyword analyzer even for all-Latin text, so romanised
"Singlish" ("honda wadak but bit late") is handled, not just Sinhala script.
"""

from __future__ import annotations

import logging

from app.core.config import settings

from .base import (
    SentimentResult,
    confidence_from,
    score_to_emotion,
    score_to_label,
    score_to_stars,
)
from .lexicon import VaderAnalyzer
from .sinhala import SinhalaKeywordAnalyzer, sinhala_ratio

logger = logging.getLogger(__name__)

_MOSTLY_SINHALA = 0.5


class SentimentService:
    def __init__(self, backend: str = "lexicon") -> None:
        if backend == "transformer":
            # A HuggingFace RoBERTa backend (BRD recommendation) plugs in here.
            # Not bundled by default to keep the image light; fall back safely.
            logger.warning("Sentiment backend 'transformer' not installed; using lexicon backend.")
        self._english = VaderAnalyzer()
        self._sinhala = SinhalaKeywordAnalyzer()
        self.version = f"composite:{self._english.version}+{self._sinhala.version}"

    def analyze(self, text: str) -> SentimentResult:
        si = self._sinhala.analyze(text, language="si")
        if sinhala_ratio(text) > _MOSTLY_SINHALA:
            return si
        en = self._english.analyze(text, language="en")
        if si.keywords:  # Sinhala or romanised Singlish sentiment words present
            return self._blend(en, si, text)
        return en

    def _blend(self, en: SentimentResult, si: SentimentResult, text: str) -> SentimentResult:
        score = round((en.score + si.score) / 2, 3)
        tokens = len(text.split())
        return SentimentResult(
            label=score_to_label(score),
            score=score,
            star_rating=score_to_stars(score),
            confidence=confidence_from(score, tokens),
            emotion=score_to_emotion(score),
            language="mixed",
            keywords=(si.keywords + en.keywords)[:5],
            analyzer_version=f"{en.analyzer_version}+{si.analyzer_version}",
        )


_service: SentimentService | None = None


def get_service() -> SentimentService:
    global _service
    if _service is None:
        _service = SentimentService(backend=getattr(settings, "sentiment_backend", "lexicon"))
    return _service
