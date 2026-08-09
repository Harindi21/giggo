"""Unit tests for the sentiment analyzer (no HTTP layer)."""

from app.services.sentiment import analyze


def test_positive_english():
    r = analyze("He did a great job, very friendly and fast!")
    assert r.label == "positive"
    assert r.star_rating >= 4
    assert r.language == "en"
    assert r.emotion in {"approval", "satisfaction"}


def test_negation_understood():
    # A key win over TextBlob: "not bad" is positive, not negative.
    r = analyze("The work was not bad at all")
    assert r.label != "negative"


def test_negative_english():
    r = analyze("Terrible service, he was rude and arrived very late")
    assert r.label == "negative"
    assert r.star_rating <= 2
    assert r.emotion in {"dissatisfaction", "frustration"}


def test_star_rating_in_range():
    for text in ["amazing", "ok", "awful and slow"]:
        r = analyze(text)
        assert 1 <= r.star_rating <= 5


def test_sinhala_positive():
    r = analyze("හොඳ වැඩක් නියමයි")  # "good work, excellent"
    assert r.language == "si"
    assert r.label == "positive"
    assert r.star_rating >= 4


def test_romanised_singlish_detected():
    # Pure Latin text but Singlish: "good work but a bit late".
    r = analyze("honda wadak but bit late")
    assert r.language == "mixed"
    assert "honda" in r.keywords
    assert r.label != "negative"


def test_keywords_extracted():
    r = analyze("excellent and professional, highly recommended")
    assert r.keywords


def test_confidence_bounds():
    r = analyze("good")
    assert 0.0 <= r.confidence <= 1.0
