VERSION = "stub-0.1.0"

_POSITIVE = {"good", "great", "excellent", "perfect", "fast", "friendly"}
_NEGATIVE = {"bad", "late", "rude", "poor", "slow", "terrible"}


def analyse(text: str) -> tuple[str, float, float]:
    """Placeholder logic. Replaced by a transformer model in P6."""
    words = {w.strip(".,!?").lower() for w in text.split()}
    pos = len(words & _POSITIVE)
    neg = len(words & _NEGATIVE)

    if pos == neg:
        return "neutral", 0.0, 0.3

    score = (pos - neg) / max(pos + neg, 1)
    label = "positive" if score > 0 else "negative"
    return label, round(score, 3), 0.4