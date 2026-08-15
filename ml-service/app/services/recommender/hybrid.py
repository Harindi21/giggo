"""Hybrid recommender (pure Python, no heavy deps).

Blends four signals into a single 0..1 score per candidate provider:

* collaborative — item-item cosine similarity on the interaction matrix
  ("providers booked by customers like you"),
* content       — affinity to the categories/districts the customer has booked,
* quality       — the Bayesian rating + experience (also the cold-start signal),
* proximity     — distance to the customer's location (optional).

Weights adapt to how much history the customer has, so new customers still get
sensible, quality-led results (cold start) while returning customers get
personalised ones.
"""

from __future__ import annotations

from collections import defaultdict

from app.schemas.recommendation import RecommendationRequest, RecommendedProvider

from .base import cosine, haversine_km, normalize, proximity_score, quality_score

# Blend weights when the customer has interaction history.
_W_CF = 0.5
_W_CONTENT = 0.2
_W_QUALITY = 0.2
_W_PROX = 0.1
# Cold-start weights (no history): lean on quality + proximity.
_W_COLD_QUALITY = 0.8
_W_COLD_PROX = 0.2

_REASONS = {
    "collaborative": "Popular with customers like you",
    "content": "Matches services you've booked before",
    "quality": "Highly rated on GIGGO",
    "proximity": "Close to your location",
}


class HybridRecommender:
    version = "hybrid-1.0"

    def recommend(
        self, req: RecommendationRequest
    ) -> tuple[str, list[RecommendedProvider]]:
        candidates = {c.provider_id: c for c in req.candidates}
        if not candidates:
            return "cold_start", []

        user_items, item_users = self._matrices(req)
        history = user_items.get(req.customer_id, {})
        has_location = req.latitude is not None and req.longitude is not None

        quality = {
            pid: quality_score(c.avg_rating, c.jobs_completed)
            for pid, c in candidates.items()
        }
        prox = self._proximity(req, candidates) if has_location else {}
        cf_raw = self._collaborative(candidates, history, item_users)
        cf = normalize(cf_raw)
        content_raw = self._content(candidates, history)
        content = normalize(content_raw)

        scored: list[tuple[str, float, str, float]] = []
        for pid, c in candidates.items():
            if req.exclude_interacted and pid in history:
                continue
            q = quality.get(pid, 0.0)
            components = self._components(
                bool(history),
                has_location,
                cf.get(pid, 0.0),
                content.get(pid, 0.0),
                q,
                prox.get(pid, 0.0),
            )
            wsum = sum(w for w, _, _ in components) or 1.0
            score = sum(w * v for w, v, _ in components) / wsum
            reason = (
                max(components, key=lambda t: t[0] * t[1])[2]
                if score > 0
                else "quality"
            )
            scored.append((pid, round(score, 6), reason, q))

        # Highest score first; Bayesian quality breaks ties.
        scored.sort(key=lambda r: (r[1], r[3]), reverse=True)
        top = scored[: req.limit]

        strategy = self._strategy(history, cf_raw, content_raw)
        return strategy, [
            RecommendedProvider(
                provider_id=pid, score=score, reason=_REASONS.get(rk, "Recommended for you")
            )
            for pid, score, rk, _ in top
        ]

    # ---- signal builders ----
    @staticmethod
    def _matrices(
        req: RecommendationRequest,
    ) -> tuple[dict[str, dict[str, float]], dict[str, dict[str, float]]]:
        user_items: dict[str, dict[str, float]] = defaultdict(dict)
        item_users: dict[str, dict[str, float]] = defaultdict(dict)
        for it in req.interactions:
            if it.weight <= 0:
                continue
            prev_u = user_items[it.customer_id].get(it.provider_id, 0.0)
            user_items[it.customer_id][it.provider_id] = max(prev_u, it.weight)
            prev_i = item_users[it.provider_id].get(it.customer_id, 0.0)
            item_users[it.provider_id][it.customer_id] = max(prev_i, it.weight)
        return user_items, item_users

    @staticmethod
    def _proximity(req, candidates) -> dict[str, float]:
        out: dict[str, float] = {}
        for pid, c in candidates.items():
            if c.latitude is not None and c.longitude is not None:
                d = haversine_km(req.latitude, req.longitude, c.latitude, c.longitude)
                out[pid] = proximity_score(d)
            else:
                out[pid] = 0.0
        return out

    @staticmethod
    def _collaborative(candidates, history, item_users) -> dict[str, float]:
        if not history:
            return {}
        out: dict[str, float] = {}
        for pid in candidates:
            if pid in history:
                continue
            target_vec = item_users.get(pid)
            if not target_vec:
                continue
            s = sum(
                hw * cosine(target_vec, item_users.get(hpid, {}))
                for hpid, hw in history.items()
            )
            if s > 0:
                out[pid] = s
        return out

    @staticmethod
    def _content(candidates, history) -> dict[str, float]:
        if not history:
            return {}
        cat_pref: dict[str, float] = defaultdict(float)
        dist_pref: dict[str, float] = defaultdict(float)
        for hpid, hw in history.items():
            feat = candidates.get(hpid)  # known only if a past provider is a candidate
            if not feat:
                continue
            for cid in feat.category_ids:
                cat_pref[cid] += hw
            if feat.district:
                dist_pref[feat.district.lower()] += hw
        if not cat_pref and not dist_pref:
            return {}
        out: dict[str, float] = {}
        for pid, c in candidates.items():
            if pid in history:
                continue
            cs = sum(cat_pref.get(cid, 0.0) for cid in c.category_ids)
            ds = dist_pref.get(c.district.lower(), 0.0) if c.district else 0.0
            total = cs + 0.5 * ds
            if total > 0:
                out[pid] = total
        return out

    @staticmethod
    def _components(
        has_history: bool,
        has_location: bool,
        cf: float,
        content: float,
        quality: float,
        prox: float,
    ) -> list[tuple[float, float, str]]:
        if has_history:
            comps = [
                (_W_CF, cf, "collaborative"),
                (_W_CONTENT, content, "content"),
                (_W_QUALITY, quality, "quality"),
            ]
            if has_location:
                comps.append((_W_PROX, prox, "proximity"))
        else:
            comps = [(_W_COLD_QUALITY, quality, "quality")]
            if has_location:
                comps.append((_W_COLD_PROX, prox, "proximity"))
        return comps

    @staticmethod
    def _strategy(history, cf_raw, content_raw) -> str:
        if not history:
            return "cold_start"
        if cf_raw:
            return "hybrid"
        if content_raw:
            return "content"
        return "cold_start"
