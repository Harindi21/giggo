# GIGGO — Build Status & Roadmap

A snapshot of what's built. The rebuild is **showcase-complete**: the full P0–P13
roadmap is delivered on both the backend and the Flutter app, cross-checked
endpoint-by-endpoint. Every feature follows one-task-per-branch PRs and ships
green (backend tests + `flutter analyze` + ML test suite).

## At a glance
- **3 services:** Flutter app · Spring Boot API (Java 21) · FastAPI ML service
- **Database:** PostgreSQL, **23 Flyway migrations** (schema is migration-only)
- **Tests:** ~**120 backend** unit/integration (incl. a full-context Testcontainers
  run) + **42 Flutter** + **21 ML** — all green
- **AI/ML: 4 of 5** components live (#4 demand forecasting deferred by design)
- **9 ADRs** capture the key architecture decisions
- **All four bottom-nav tabs are real** — no placeholder screens

## Phases

| Phase | Scope | Status |
|---|---|---|
| P0–P1 | Tooling, auth (JWT, refresh, RBAC, lockout, account deletion, **email-OTP verification screen**) | ✅ Done |
| P2 | **Provider profiles** (self-service editor: bio, rates, service area, skills, availability); **KYC verification** (submit → admin approve → verified badge) | ✅ Done |
| P3 | Discovery (search/detail) + **hybrid recommendation** (AI #3) | ✅ Done |
| P4 | Booking: pricing, creation, **job state machine**, all Flutter screens, expiry + cancel/refund policy, **disputes**, **anti-fraud guards**, **receipt/invoice** | ✅ Done |
| P5 | **Real-time tracking** (WebSocket, consent, ETA) on a live **OpenStreetMap** | ✅ Done |
| P6 | Reviews + **NLP sentiment** (AI #1), **Bayesian rating** (AI #2), **fair ranking** (AI #5), **admin moderation** | ✅ Done |
| P7 | **Payments + escrow** (capture → hold → release/refund; PayHere seam) | ✅ Done |
| P8 | **Notifications** (event-driven; FCM push seam) + inbox + **escrow-captured push** + **device-token registration** | ✅ Done |
| P9 | **Knowledge Hub** (articles) | ✅ Done |
| P10 | **Tool Marketplace** (catalog + **orders/checkout** via the escrow engine) | ✅ Done |
| P11 | **Admin** (KYC review, disputes queue, review moderation) | ✅ Done |
| P12 | **Testcontainers CI** — full context + all migrations + e2e booking→payment→review flow | ✅ Done |
| P13 | Deploy config + app-store listing prep (icons, screenshots, privacy policy) | ✅ Done |
| — | AI #4 demand forecasting | ⏸️ Phase 2 (seam in place) |

## Feature checklist

**Customer:** discover · recommended-for-you · provider detail + reviews ·
book (live quote) · booking list + status timeline · live tracking + ETA (OSM) ·
pay via escrow + refund · **receipt/invoice** · rate & review · raise a dispute ·
notifications · knowledge hub · shop (buy tools via escrow).

**Provider:** **manage my profile** (bio, rates, service area, skills, availability
toggle) · my jobs (accept → en route → start → complete) · get verified (KYC) ·
receive job / review / payment / escrow-secured notifications · verified badge.

**Admin:** KYC review queue · disputes queue (resolve refund/dismiss) · review
moderation (report → hide/restore); article & tool authoring via API.

## Integration seams (stub today → real for GA)

| Capability | Default (works now) | GA swap |
|---|---|---|
| Review sentiment | VADER lexicon + Sinhala | RoBERTa (`SENTIMENT_BACKEND=transformer`) |
| Recommendation | pure-Python hybrid | LightFM (`RECOMMENDER_BACKEND=lightfm`) |
| Maps / tracking | **live OpenStreetMap** + Haversine ETA (keyless) | routing/traffic API for turn-by-turn ETA |
| Payments | stub gateway | PayHere (`giggo.payments.gateway=payhere`) |
| Push | logging stub | FCM (`giggo.notifications.push-provider=fcm`) |
| Email | log provider | real email provider (`EMAIL_PROVIDER`) |

Every seam has a working keyless default, so nothing is blocked today; swapping in
real provider keys is a no-op wiring change (see [`adr/0001`](adr/0001-integration-seams-with-stub-defaults.md)).

## What's left (post-showcase)
- **AI #4 — demand forecasting** (Phase 2): per-district/skill booking-volume
  trends to guide provider supply; the stateless-ML seam is already in place.
- **Real provider keys** — plug real values into the seams above.
- **i18n depth** — `en`/`si` localization is scaffolded (ARB + delegates wired);
  threading `AppLocalizations` through every screen + a language switcher remains.
- **Store submission** — listing assets are prepared; actual submission is an
  operational step.

See [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) to run it, [`DEPLOYMENT.md`](DEPLOYMENT.md)
to ship it, [`STORE_LISTING.md`](STORE_LISTING.md) + [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)
for release, [`adr/`](adr/README.md) for the key architecture decisions,
[`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md) for the research framing, and
[`PORTFOLIO_ONEPAGER.md`](PORTFOLIO_ONEPAGER.md) for the summary.
