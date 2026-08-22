-- Knowledge Hub article metrics (P9.4): view count + a simple rating tally
-- (sum/count -> average). No per-user dedupe (parity with review reports).

ALTER TABLE articles ADD COLUMN view_count   INTEGER NOT NULL DEFAULT 0;
ALTER TABLE articles ADD COLUMN rating_sum    INTEGER NOT NULL DEFAULT 0;
ALTER TABLE articles ADD COLUMN rating_count  INTEGER NOT NULL DEFAULT 0;
