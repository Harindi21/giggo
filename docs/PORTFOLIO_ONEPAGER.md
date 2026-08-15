# GIGGO — Smart Service Marketplace (Portfolio One-Pager)

**Role:** Tech Lead / Full-stack + ML · **Type:** Final-year thesis, rebuilt to
production standards · **Region:** Sri Lanka

---

## The product
A two-sided marketplace connecting customers with trusted local service
professionals (plumbing, electrical, moving, lifestyle, vehicle, and more). The
trust and discovery layers are driven by **five AI/ML components**; the whole
journey works end-to-end from both the customer and provider apps.

**Customer:** discover → *recommended for you* → book (live price) → track live →
pay via escrow → review. **Provider:** receive requests → accept → en route →
start → complete → get paid.

## Architecture
Monorepo, three services:
- **Flutter** app (Riverpod, GoRouter, Dio) — customer + provider, one role-aware UI.
- **Spring Boot** API (Java 21, JWT, JPA, Flyway) — domain-driven modules.
- **FastAPI** ML service (Python) — sentiment + recommender.
- **PostgreSQL** (17 Flyway migrations) + **Redis**; real-time via **STOMP/WebSocket**.

Every external dependency (Google Maps, PayHere, FCM, RoBERTa, LightFM) sits
behind an **adapter with a working stub default**, selected by config — the
system runs fully with **zero paid API keys**, and swapping in a real provider is
a one-line change.

## AI / ML (4 of 5 built; #4 is Phase-2 by design)
1. **Multilingual review sentiment** — VADER + optional RoBERTa, with a
   **Sinhala/Singlish** path and blending for mixed text.
2. **Bayesian composite rating** — star + text-sentiment blend, shrinkage prior
   so low-review providers aren't over-ranked.
3. **Hybrid recommender** — collaborative filtering + content + quality +
   proximity, with graceful cold-start.
4. **Demand forecasting** — *Phase 2 (seam in place).*
5. **Fair ranking** — regional-diversity post-processor for equitable exposure.

## Selected engineering
- **Booking lifecycle** state machine with an auditable status timeline.
- **Escrow payments** (capture → hold → release, platform-commission split).
- **Real-time tracking** — JWT-authenticated WebSocket, consent-gated location,
  Haversine ETA.
- **Event-driven notifications** — after-commit, per-recipient, push seam.
- **Process** — one task per branch → PR → merge; conventional commits; ~74
  backend tests + a Python ML test suite; DB migrations only (no drift);
  fail-soft cross-service calls.

## Tech stack
`Flutter` · `Riverpod` · `Dart` · `Java 21` · `Spring Boot` · `Spring Security
(JWT)` · `JPA/Hibernate` · `Flyway` · `PostgreSQL` · `Redis` · `STOMP/WebSocket`
· `Python` · `FastAPI` · `VADER` · `RoBERTa (transformers)` · `Docker`

## Status
End-to-end spine complete and demoable: discovery, recommendation, booking +
job lifecycle, live tracking, reviews/NLP, escrow payments, notifications.
Remaining for GA: KYC, real gateway/push keys, store listings, Testcontainers
CI. See [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) to run it and [`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md)
for the research framing.
