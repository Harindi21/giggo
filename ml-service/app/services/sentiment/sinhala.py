"""Sinhala / Singlish (code-switched) sentiment fallback.

Sri Lankan reviews are often written in Sinhala or romanised "Singlish"
("honda wadak but bit late"). English-only analyzers score these as neutral,
which the BRD flags as a critical gap. This is the Phase-1 approach the AI note
prescribes: a keyword lexicon over both Sinhala script and common romanisations.
A fine-tuned SinhalaBERT model is the Phase-2 upgrade behind the same interface.
"""

from __future__ import annotations

import re

from .base import (
    SentimentResult,
    confidence_from,
    score_to_emotion,
    score_to_label,
    score_to_stars,
)

_SINHALA_START = 0x0D80
_SINHALA_END = 0x0DFF

# Sinhala-script words are matched as substrings (tolerant of suffixes/inflection).
_POSITIVE_SI = {
    "හොඳ", "හොඳයි", "සුපිරි", "පට්ට", "ලස්සන", "නියම", "නියමයි",
    "දක්ෂ", "ස්තූති", "ස්තූතියි", "සතුටු", "සතුටුයි", "වේගවත්", "පිරිසිදු",
}
_NEGATIVE_SI = {
    "නරක", "අවුල්", "ප්‍රමාද", "පරක්කු", "කම්මැලි", "දුර්වල", "කරදර", "නොහොඳ",
}

# Romanised "Singlish" tokens (matched on whole words, lowercased).
_POSITIVE_ROMAN = {
    "honda", "hondai", "hodai", "hoda", "niyama", "niyamai", "patta",
    "supiri", "lassana", "laasan", "daksha", "sathutui", "wegawath", "pirisidu",
}
_NEGATIVE_ROMAN = {
    "naraka", "awul", "awula", "prumada", "parakku", "kammeli",
    "durwala", "karadara", "nohoda",
}

_LATIN_WORD_RE = re.compile(r"[a-z']+")


def contains_sinhala(text: str) -> bool:
    return any(_SINHALA_START <= ord(c) <= _SINHALA_END for c in text)


def sinhala_ratio(text: str) -> float:
    letters = [c for c in text if c.isalpha()]
    if not letters:
        return 0.0
    si = sum(1 for c in letters if _SINHALA_START <= ord(c) <= _SINHALA_END)
    return si / len(letters)


class SinhalaKeywordAnalyzer:
    version = "sinhala-keyword-0.1.0"

    def analyze(self, text: str, language: str = "si") -> SentimentResult:
        lowered = text.lower()
        roman_tokens = set(_LATIN_WORD_RE.findall(lowered))

        matched: list[str] = []
        pos = neg = 0

        for w in _POSITIVE_SI:
            if w in text:
                pos += 1
                matched.append(w)
        for w in _NEGATIVE_SI:
            if w in text:
                neg += 1
                matched.append(w)
        for w in _POSITIVE_ROMAN & roman_tokens:
            pos += 1
            matched.append(w)
        for w in _NEGATIVE_ROMAN & roman_tokens:
            neg += 1
            matched.append(w)

        # Add-one smoothing keeps a single keyword from pinning the score to ±1.
        denom = pos + neg + 1
        score = round((pos - neg) / denom, 3)
        token_count = len(text.split())

        return SentimentResult(
            label=score_to_label(score),
            score=score,
            star_rating=score_to_stars(score),
            confidence=confidence_from(score, token_count),
            emotion=score_to_emotion(score),
            language=language,
            keywords=matched[:5],
            analyzer_version=self.version,
        )
