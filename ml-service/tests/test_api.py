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


def test_recommendations_require_api_key():
    res = client.post("/api/v1/recommendations", json={"customer_id": "u1"})
    assert res.status_code == 401


def test_recommendations_rank_candidates():
    res = client.post(
        "/api/v1/recommendations",
        headers={"X-API-Key": "local-dev-key"},
        json={
            "customer_id": "u1",
            "limit": 5,
            "candidates": [
                {"provider_id": "p1", "avg_rating": 3.0, "jobs_completed": 2},
                {"provider_id": "p2", "avg_rating": 4.9, "jobs_completed": 40},
            ],
        },
    )
    assert res.status_code == 200
    body = res.json()
    assert body["strategy"] == "cold_start"
    assert body["results"][0]["provider_id"] == "p2"