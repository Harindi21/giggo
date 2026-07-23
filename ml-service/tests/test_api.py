from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_is_open():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "ok"


def test_sentiment_requires_api_key():
    res = client.post("/api/v1/sentiment", json={"text": "great work"})
    assert res.status_code == 401


def test_sentiment_returns_positive():
    res = client.post(
        "/api/v1/sentiment",
        json={"text": "great and friendly service"},
        headers={"X-API-Key": "local-dev-key"},
    )
    assert res.status_code == 200
    assert res.json()["label"] == "positive"