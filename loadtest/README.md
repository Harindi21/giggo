# Load tests — real-time tracking socket (WBS P5.10)

Validates that the STOMP-over-WebSocket tracking endpoint (`/ws`) holds **200
concurrent connections** (BRD NFR: "Load test: 200 concurrent WebSocket
connections"). Each simulated client opens the socket, sends a JWT-authenticated
STOMP `CONNECT`, subscribes to a job's location topic, and holds.

## Prerequisites
- Backend running with demo data (so the login user exists):
  ```bash
  cd backend && SEED_DEMO_DATA=true ./mvnw spring-boot:run
  ```
  (Adjust the URL below if you run on a port other than 8080/8081.)

## Option A — Python (no extra tooling)
```bash
pip install websockets
py loadtest/ws_load_test.py 200 http://localhost:8081
```
Prints connected/failed counts, connect-time percentiles (p50/p95/max) and any
failure classes.

## Option B — k6 (the standard load-testing tool)
```bash
# install: winget install k6  (or https://k6.io/docs/get-started/installation/)
BASE_URL=http://localhost:8081 WS_URL=ws://localhost:8081 k6 run loadtest/ws-load-test.js
```
Ramps 0 → 200 → 0 VUs. Thresholds: 95% of handshakes < 1s, > 99% of clients
upgrade + STOMP-connect.

## Notes
- Both use the seeded demo customer (`demo.customer@giggo.lk`) purely to obtain a
  valid JWT for the STOMP `CONNECT` frame.
- The in-memory STOMP broker is single-instance (Phase 1). For multi-instance
  horizontal scale, front it with a RabbitMQ/Redis relay and re-run.
