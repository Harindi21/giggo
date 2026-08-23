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
- **FastAPI** ML service (Python) — sentiment, recommender, demand forecasting.
- **PostgreSQL** (32 Flyway migrations) + **Redis**; real-time via **STOMP/WebSocket**.

Every paid external dependency (PayHere, FCM, RoBERTa, LightFM) sits behind an
**adapter with a working stub default**, selected by config — the system runs
fully with **zero paid API keys** (maps use keyless **OpenStreetMap**), and
swapping in a real provider is a one-line change.

## AI / ML (all five built)
1. **Multilingual review sentiment** — VADER + optional RoBERTa, with a
   **Sinhala/Singlish** path and blending for mixed text.
2. **Bayesian composite rating** — star + text-sentiment blend, shrinkage prior
   so low-review providers aren't over-ranked.
3. **Hybrid recommender** — collaborative filtering + content + quality +
   proximity, with graceful cold-start.
4. **Demand forecasting** — stateless linear-trend over a weekly booking series
   (backend-derived), with a naive fallback; Prophet/ARIMA-ready seam.
5. **Fair ranking** — regional-diversity post-processor for equitable exposure.

## Selected engineering
- **Booking lifecycle** state machine with an auditable status timeline, plus
  disputes, rule-based **anti-fraud guards**, and a **receipt/invoice**.
- **Escrow payments** (capture → hold → release, platform-commission split),
  reused for the Tool Marketplace's direct-sale orders.
- **Real-time tracking** — JWT-authenticated WebSocket, consent-gated location,
  Haversine ETA, on a live **OpenStreetMap**.
- **Event-driven notifications** — after-commit, per-recipient, push seam, with
  in-app device-token registration.
- **Two-sided by design** — provider self-service profile (rates, service area,
  skills, weekly availability), earnings & payouts, demand insights, KYC; and an
  admin console (KYC, disputes, review moderation, analytics dashboard, audit log).
- **Process** — one task per branch → PR → merge; conventional commits; ~170
  backend + 60 Flutter + 27 ML tests (incl. a full-context Testcontainers run, a
  k6 500-user load test, and an NLP-accuracy eval); DB migrations only (no drift);
  fail-soft cross-service calls; **11 ADRs**.

## Tech stack
`Flutter` · `Riverpod` · `Dart` · `Java 21` · `Spring Boot` · `Spring Security
(JWT)` · `JPA/Hibernate` · `Flyway` · `PostgreSQL` · `Redis` · `STOMP/WebSocket`
· `Python` · `FastAPI` · `VADER` · `RoBERTa (transformers)` · `Docker`

## Status
Feature-complete for the roadmap: every **P0–P13** task buildable without
third-party accounts is delivered end-to-end on both roles — discovery +
recommendation + nearby map, booking lifecycle (expiry/cancel/refund, disputes,
receipts, anti-fraud, double-booking prevention), live tracking, reviews/NLP +
moderation + rating breakdown, escrow payments + provider earnings/payouts, all
**five AI/ML components** (incl. demand forecasting), notifications (preferences +
delivery retry), Knowledge Hub (search + recommendations), Tool Marketplace
(escrow orders + wishlist), and a full admin console (analytics, audit log,
payouts, moderation). All four app tabs are real; ~170 backend + 60 Flutter + 27
ML tests, 32 DB migrations, a full-context Testcontainers run + a k6 500-user load
test, all green. What remains needs *external accounts or ops*, not code: real
provider keys (PayHere/FCM/SMS/S3/OAuth), hosting + store submission, and deeper
`en`/`si` localization. See [`STATUS.md`](STATUS.md) for the full breakdown,
[`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) to run it, and
[`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md) for the research framing.
