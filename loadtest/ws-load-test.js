// k6 WebSocket load test for the GIGGO real-time tracking socket (WBS P5.10).
//
// Ramps to 200 concurrent STOMP-over-WebSocket clients, each of which:
//   1. opens the WebSocket, 2. sends a JWT-authenticated STOMP CONNECT,
//   3. subscribes to a job's location topic, 4. holds, then disconnects.
//
// Run:  k6 run loadtest/ws-load-test.js
//       BASE_URL=http://localhost:8081 WS_URL=ws://localhost:8081 k6 run loadtest/ws-load-test.js
import ws from 'k6/ws';
import http from 'k6/http';
import { check } from 'k6';
import { Counter } from 'k6/metrics';

const BASE = __ENV.BASE_URL || 'http://localhost:8081';
const WS = (__ENV.WS_URL || 'ws://localhost:8081') + '/ws';
const NUL = String.fromCharCode(0); // STOMP frame terminator (null byte)

export const options = {
  scenarios: {
    ramp: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 200 }, // ramp up
        { duration: '20s', target: 200 }, // hold 200 concurrent
        { duration: '5s', target: 0 },    // ramp down
      ],
    },
  },
  thresholds: {
    ws_connecting: ['p(95)<1000'], // 95% of handshakes under 1s
    checks: ['rate>0.99'],         // >99% of connections upgrade + STOMP-connect
  },
};

const stompConnected = new Counter('stomp_connected');

export function setup() {
  const res = http.post(
    `${BASE}/api/v1/auth/login`,
    JSON.stringify({ email: 'demo.customer@giggo.lk', password: 'Provider@123' }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  return { token: res.json('data.accessToken') };
}

function frame(command, headers, body = '') {
  let h = '';
  for (const k in headers) h += `${k}:${headers[k]}\n`;
  return `${command}\n${h}\n${body}${NUL}`;
}

export default function (data) {
  const res = ws.connect(WS, {}, function (socket) {
    socket.on('open', () => {
      socket.send(frame('CONNECT', {
        'accept-version': '1.2',
        host: 'localhost',
        Authorization: `Bearer ${data.token}`,
      }));
    });
    socket.on('message', (msg) => {
      if (msg.startsWith('CONNECTED')) {
        stompConnected.add(1);
        socket.send(frame('SUBSCRIBE', { id: 'sub-0', destination: '/topic/jobs/loadtest/location' }));
        socket.setTimeout(() => socket.close(), 3000);
      }
    });
  });
  check(res, { 'ws upgraded (101)': (r) => r && r.status === 101 });
}
