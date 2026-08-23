// REST API load test (WBS P12.5): 500 concurrent users.
//
// Logs in once (setup) as the seeded demo customer to obtain a JWT, then ramps
// to 500 VUs hammering the hot read paths (discovery, catalog, recommendations)
// plus the public health check. Reports latency percentiles and error rate.
//
//   winget install k6   (or https://k6.io/docs/get-started/installation/)
//   BASE_URL=http://localhost:8080 k6 run loadtest/api_load_test.js
//
// Env: BASE_URL (default http://localhost:8080), EMAIL, PASSWORD.

import http from 'k6/http';
import { check, sleep, group } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const EMAIL = __ENV.EMAIL || 'demo.customer@giggo.lk';
const PASSWORD = __ENV.PASSWORD || 'Provider@123';
const API = `${BASE_URL}/api/v1`;

export const options = {
  stages: [
    { duration: '1m', target: 100 },   // warm up
    { duration: '2m', target: 500 },   // ramp to 500 concurrent users
    { duration: '2m', target: 500 },   // hold peak
    { duration: '1m', target: 0 },     // ramp down
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],          // < 1% errors
    http_req_duration: ['p(95)<1000'],       // 95% under 1s
  },
};

export function setup() {
  const res = http.post(
    `${API}/auth/login`,
    JSON.stringify({ email: EMAIL, password: PASSWORD }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  check(res, { 'login ok': (r) => r.status === 200 });
  const token = res.status === 200 ? res.json('data.accessToken') : null;
  return { token };
}

export default function (data) {
  const authHeaders = data.token
    ? { headers: { Authorization: `Bearer ${data.token}` } }
    : { headers: {} };

  group('public health', () => {
    const r = http.get(`${BASE_URL}/api/health`);
    check(r, { 'health 200': (res) => res.status === 200 });
  });

  group('browse catalog', () => {
    const r = http.get(`${API}/catalog/categories`, authHeaders);
    check(r, { 'categories 200': (res) => res.status === 200 });
  });

  group('search providers', () => {
    const r = http.get(`${API}/providers`, authHeaders);
    check(r, { 'providers 200': (res) => res.status === 200 });
  });

  group('recommendations', () => {
    const r = http.get(`${API}/recommendations?limit=10`, authHeaders);
    check(r, { 'recommendations 2xx': (res) => res.status >= 200 && res.status < 300 });
  });

  sleep(1);
}
