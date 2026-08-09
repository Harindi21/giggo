from .base import SentimentResult
from .service import SentimentService, get_service


def analyze(text: str) -> SentimentResult:
    """Convenience wrapper around the shared service instance."""
    return get_service().analyze(text)


__all__ = ["SentimentResult", "SentimentService", "get_service", "analyze"]
