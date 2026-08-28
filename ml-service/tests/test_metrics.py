from app.services.assistant.metrics import (
    MetricsStore,
    RequestTrace,
    check_alerts,
    estimate_cost,
    estimate_tokens,
    percentile,
)


def _trace(latency, cost=0.0, grounded=True):
    return RequestTrace(
        at=0.0,
        latency_ms=latency,
        retrieved=2,
        tokens_in=10,
        tokens_out=20,
        cost_usd=cost,
        grounded=grounded,
        refused=not grounded,
    )


def test_estimate_tokens_and_cost():
    assert estimate_tokens("") == 0
    assert estimate_tokens("one two three") == 4  # 3 * 1.3 -> 4
    assert estimate_cost(1000, 1000) == 0.0  # local prices default to free


def test_percentile():
    values = [10.0, 20.0, 30.0, 40.0, 50.0]
    assert percentile(values, 0.5) == 30.0
    assert percentile([], 0.9) == 0.0


def test_snapshot_aggregates_traces():
    store = MetricsStore()
    assert store.snapshot()["requests"] == 0
    for latency in (100.0, 200.0, 300.0):
        store.record(_trace(latency))
    snap = store.snapshot()
    assert snap["requests"] == 3
    assert snap["latency_ms"]["p50"] == 200.0
    assert snap["grounded_rate"] == 1.0
    assert snap["refusal_rate"] == 0.0
    assert snap["alerts"] == []


def test_alert_fires_on_latency_breach():
    snap = {
        "latency_ms": {"p95": 3000.0},
        "cost_usd": {"avg_per_question": 0.0},
        "refusal_rate": 0.0,
    }
    assert any(a["metric"] == "p95_latency_ms" for a in check_alerts(snap))


def test_alert_fires_on_high_refusal():
    snap = {
        "latency_ms": {"p95": 0.0},
        "cost_usd": {"avg_per_question": 0.0},
        "refusal_rate": 0.90,
    }
    assert any(a["metric"] == "refusal_rate" for a in check_alerts(snap))
