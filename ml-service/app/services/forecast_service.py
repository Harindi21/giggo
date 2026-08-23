"""Demand forecasting (AI #4).

A dependency-light least-squares linear trend over a demand series (e.g. weekly
booking counts), projecting the next ``horizon`` periods and classifying the
trend. Stateless — the backend supplies the series, we return the projection.
A heavier model (Prophet / ARIMA) can replace this behind the same contract.
"""


def forecast(series: list[float], horizon: int = 1) -> tuple[list[float], str, str]:
    horizon = max(1, horizon)
    values = [float(v) for v in series]
    n = len(values)

    if n == 0:
        return [], "steady", "empty"
    if n == 1:
        return [max(0.0, values[0])] * horizon, "steady", "flat"

    xs = list(range(n))
    mean_x = sum(xs) / n
    mean_y = sum(values) / n
    denom = sum((x - mean_x) ** 2 for x in xs) or 1.0
    slope = sum((xs[i] - mean_x) * (values[i] - mean_y) for i in range(n)) / denom
    intercept = mean_y - slope * mean_x

    preds = [
        round(max(0.0, intercept + slope * (n - 1 + h)), 2)
        for h in range(1, horizon + 1)
    ]

    # Classify against a small fraction of the average level so tiny wiggles read as steady.
    threshold = 0.1 * (mean_y if mean_y else 1.0)
    if slope > threshold:
        trend = "rising"
    elif slope < -threshold:
        trend = "falling"
    else:
        trend = "steady"

    return preds, trend, "linear-trend"
