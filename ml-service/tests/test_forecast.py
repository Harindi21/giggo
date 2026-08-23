from fastapi.testclient import TestClient

from app.main import app
from app.services import forecast_service

client = TestClient(app)


def test_forecast_requires_api_key():
    res = client.post("/api/v1/forecast", json={"series": [1, 2, 3]})
    assert res.status_code == 401


def test_forecast_projects_rising_series():
    res = client.post(
        "/api/v1/forecast",
        json={"series": [2, 4, 6, 8], "horizon": 2},
        headers={"X-API-Key": "local-dev-key"},
    )
    assert res.status_code == 200
    body = res.json()
    assert body["trend"] == "rising"
    assert len(body["forecast"]) == 2
    assert body["forecast"][0] >= 8  # continues upward


def test_service_handles_short_and_empty_series():
    assert forecast_service.forecast([], 1) == ([], "steady", "empty")
    preds, trend, _ = forecast_service.forecast([5], 3)
    assert preds == [5.0, 5.0, 5.0]
    assert trend == "steady"


def test_service_detects_falling_trend_and_floors_at_zero():
    preds, trend, _ = forecast_service.forecast([10, 7, 4, 1], 3)
    assert trend == "falling"
    assert all(p >= 0 for p in preds)  # never negative
