# GIGGO — Build Status & Roadmap

A snapshot of what's built (showcase-complete) and what remains for a General
Availability (GA) release. Every feature below is delivered on both the backend
and the Flutter app unless noted, follows one-task-per-branch PRs, and ships
green (backend tests + `flutter analyze` + ML test suite).

## At a glance
- **3 services:** Flutter app · Spring Boot API (Java 21) · FastAPI ML service
- **Database:** PostgreSQL, **20 Flyway migrations** (schema is migration-only)
- **Tests:** ~**96 backend** unit/integration + a Python ML suite; Flutter
  analyze-clean
- **AI/ML: 4 of 5** components live (#4 demand forecasting deferred by design)
- **All four bottom-nav tabs are real** — no placeholder screens

## Phases

| Phase | Scope | Status |
|---|---|---|
| P0–P1 | Tooling, auth (JWT, email verification) | ✅ Done |
| P2 | Provider profiles; **KYC verification** (submit → admin approve → verified badge) | ✅ Done |
| P3 | Discovery (search/detail) + **hybrid recommendation** (AI #3) | ✅ Done |
| P4 | Booking: pricing, creation, **job state machine**, all Flutter screens, accept-expiry + cancel/refund policy | ✅ Done |
| P5 | **Real-time tracking** (WebSocket, consent, ETA) | ✅ Done |
| P6 | Reviews + **NLP sentiment** (AI #1), **Bayesian rating** (AI #2), **fair ranking** (AI #5) | ✅ Done |
| P7 | **Payments + escrow** (capture → hold → release/refund; PayHere seam) | ✅ Done |
| P8 | **Notifications** (event-driven; FCM push seam) + in-app inbox | ✅ Done |
| P9 | **Knowledge Hub** (articles) | ✅ Done |
| P10 | **Tool Marketplace** (catalog) | ✅ Done |
| P11 | **Admin** (in-app KYC review queue) | ✅ Done |
| — | AI #4 demand forecasting | ⏸️ Phase 2 (seam in place) |
| P12 | Testcontainers CI (full context + migrations in CI) | ⬜ Remaining |
| P13 | Deploy config + app-store listings | ⬜ Remaining |

## Feature checklist

**Customer:** discover · recommended-for-you · provider detail + reviews ·
book (live quote) · booking list + status timeline · live tracking + ETA ·
pay via escrow + refund · rate & review · notifications · knowledge hub · shop.

**Provider:** my jobs (accept → en route → start → complete) · get verified
(KYC) · receive job/review/payment notifications · verified badge.

**Admin:** verification (KYC) review queue (approve/reject); article & tool
authoring via API.

## Integration seams (stub today → real for GA)

| Capability | Default (works now) | GA swap |
|---|---|---|
| Review sentiment | VADER lexicon + Sinhala | RoBERTa (`SENTIMENT_BACKEND=transformer`) |
| Recommendation | pure-Python hybrid | LightFM (`RECOMMENDER_BACKEND=lightfm`) |
| Maps / ETA | Haversine + text | Google Maps API key |
| Payments | stub gateway | PayHere (`giggo.payments.gateway=payhere`) |
| Push | logging stub | FCM (`giggo.notifications.push-provider=fcm`) |
| Email | log provider | real email provider (`EMAIL_PROVIDER`) |

## What's left for GA
- **P12** — un-disable the `@SpringBootTest` context test with Testcontainers so
  every PR runs the full context + all migrations.
- **P13** — deployment (hosting, env, custom domain/SSL) and store listings
  (icons, screenshots, descriptions, privacy policy).
- **Real provider keys** — plug real values into the seams above (all no-ops to
  wire; nothing is blocked today).
- **Nice-to-haves** — marketplace orders/cart + checkout (reuse the escrow
  engine), payment/review-specific push events, FCM device-token registration in
  the app, and finishing the email-OTP entry screen (P1.2 partial).

See [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) to run it, [`DEPLOYMENT.md`](DEPLOYMENT.md)
to ship it, [`STORE_LISTING.md`](STORE_LISTING.md) + [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)
for release, [`adr/`](adr/README.md) for the key architecture decisions,
[`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md) for the research framing, and
[`PORTFOLIO_ONEPAGER.md`](PORTFOLIO_ONEPAGER.md) for the summary.
