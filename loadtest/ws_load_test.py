"""Runnable WebSocket load test for the GIGGO tracking socket (WBS P5.10).

Opens N concurrent STOMP-over-WebSocket clients against the backend. Each client:
  1. opens the WebSocket, 2. sends a JWT-authenticated STOMP CONNECT,
  3. waits for CONNECTED, 4. subscribes to a job's location topic, 5. holds.
Reports the number connected, connect-time percentiles and any failures.

Usage:  py loadtest/ws_load_test.py [N] [BASE_URL]
Example: py loadtest/ws_load_test.py 200 http://localhost:8081
Requires: pip install websockets
"""

import asyncio
import json
import sys
import time
import urllib.request
from collections import Counter

N = int(sys.argv[1]) if len(sys.argv) > 1 else 200
BASE = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:8081"
WS = BASE.replace("http", "ws") + "/ws"
HOLD_SECONDS = 3.0
NUL = "\x00"

import websockets  # noqa: E402  (after arg parsing so --help is cheap)


def login() -> str:
    body = json.dumps({"email": "demo.customer@giggo.lk", "password": "Provider@123"}).encode()
    req = urllib.request.Request(
        f"{BASE}/api/v1/auth/login", data=body, headers={"Content-Type": "application/json"}
    )
    return json.loads(urllib.request.urlopen(req).read())["data"]["accessToken"]


def frame(command: str, headers: dict, body: str = "") -> str:
    h = "".join(f"{k}:{v}\n" for k, v in headers.items())
    return f"{command}\n{h}\n{body}{NUL}"


async def one_client(i: int, token: str, results: list) -> None:
    start = time.monotonic()
    try:
        async with websockets.connect(WS, open_timeout=15, ping_interval=None) as ws:
            await ws.send(frame("CONNECT", {
                "accept-version": "1.2", "host": "localhost", "Authorization": f"Bearer {token}",
            }))
            reply = await asyncio.wait_for(ws.recv(), timeout=10)
            if not reply.startswith("CONNECTED"):
                results.append(("not_connected", time.monotonic() - start))
                return
            await ws.send(frame("SUBSCRIBE", {"id": f"sub-{i}", "destination": "/topic/jobs/loadtest/location"}))
            results.append(("ok", time.monotonic() - start))
            await asyncio.sleep(HOLD_SECONDS)
    except Exception as exc:  # noqa: BLE001 — record the failure class
        results.append((type(exc).__name__, time.monotonic() - start))


async def main() -> None:
    print(f"Load test: {N} concurrent WebSocket clients -> {WS}")
    token = login()
    results: list = []
    started = time.monotonic()
    await asyncio.gather(*[one_client(i, token, results) for i in range(N)])
    wall = time.monotonic() - started

    ok = sorted(d for s, d in results if s == "ok")
    failures = [s for s, _ in results if s != "ok"]

    def pctl(p: float) -> float:
        return ok[min(len(ok) - 1, int(len(ok) * p))] * 1000 if ok else 0.0

    print(f"connected: {len(ok)}/{N}   failed: {len(failures)}")
    if ok:
        print(f"connect time ms — min {ok[0]*1000:.0f} | p50 {pctl(0.5):.0f} | "
              f"p95 {pctl(0.95):.0f} | max {ok[-1]*1000:.0f}")
    print(f"wall time: {wall:.1f}s")
    if failures:
        print("failures:", dict(Counter(failures)))


if __name__ == "__main__":
    asyncio.run(main())
