"""HuggingFace RoBERTa sentiment backend (the BRD's recommended upgrade).

Uses ``cardiffnlp/twitter-roberta-base-sentiment-latest`` — a transformer that
reads the whole sentence in context (slang, negation, informal review text),
which is more accurate than the VADER lexicon on short reviews.

It is optional: ``transformers`` + ``torch`` are heavy (~hundreds of MB, needs
more RAM than free hosting tiers offer), so they live in
``requirements-transformer.txt`` and are imported lazily. Enable this backend
with ``SENTIMENT_BACKEND=transformer``; if the deps are missing the service
falls back to VADER automatically.
"""

from __future__ import annotations

from .base import (
    SentimentResult,
    score_to_emotion,
    score_to_label,
    score_to_stars,
)

_DEFAULT_MODEL = "cardiffnlp/twitter-roberta-base-sentiment-latest"


class TransformerAnalyzer:
    def __init__(self, model_name: str = _DEFAULT_MODEL) -> None:
        # Lazy, heavy imports — only pulled in when this backend is actually used.
        from transformers import pipeline

        self._pipe = pipeline("sentiment-analysis", model=model_name, top_k=None)
        self.version = f"transformer:{model_name}"

    def analyze(self, text: str, language: str = "en") -> SentimentResult:
        # top_k=None -> list of {label, score} for all classes.
        raw = self._pipe(text)
        scores = raw[0] if raw and isinstance(raw[0], list) else raw
        probs = {d["label"].lower(): float(d["score"]) for d in scores}

        pos = probs.get("positive", 0.0)
        neg = probs.get("negative", 0.0)
        compound = round(pos - neg, 3)
        confidence = round(max(probs.values()), 3) if probs else 0.0

        return SentimentResult(
            label=score_to_label(compound),
            score=compound,
            star_rating=score_to_stars(compound),
            confidence=confidence,
            emotion=score_to_emotion(compound),
            language=language,
            keywords=[],  # transformer gives no lexicon hits; VADER path supplies these
            analyzer_version=self.version,
        )
