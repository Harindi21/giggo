"""Tests for the optional RoBERTa backend.

The transformer logic is tested with a fake pipeline (no torch download needed).
The fallback test proves the service degrades to VADER when the heavy deps are
absent — the safety behaviour that keeps the default install light.
"""

from app.services.sentiment.service import SentimentService
from app.services.sentiment.transformer import TransformerAnalyzer


def _fake_analyzer(scores):
    a = TransformerAnalyzer.__new__(TransformerAnalyzer)  # skip heavy __init__
    a.version = "transformer:test"
    a._pipe = lambda text: [scores]
    return a


def test_transformer_maps_positive():
    a = _fake_analyzer([
        {"label": "positive", "score": 0.90},
        {"label": "neutral", "score": 0.07},
        {"label": "negative", "score": 0.03},
    ])
    r = a.analyze("great job")
    assert r.label == "positive"
    assert r.star_rating >= 4
    assert r.confidence == 0.9


def test_transformer_maps_negative():
    a = _fake_analyzer([
        {"label": "positive", "score": 0.05},
        {"label": "neutral", "score": 0.10},
        {"label": "negative", "score": 0.85},
    ])
    r = a.analyze("awful and late")
    assert r.label == "negative"
    assert r.star_rating <= 2


def test_service_falls_back_to_vader_without_transformer_deps():
    # transformers/torch are not installed in the default test env -> fall back.
    svc = SentimentService(backend="transformer")
    assert "vader" in svc.version
    assert svc.analyze("great and friendly service").label == "positive"
