-- Store the raw sum of ratings so the Bayesian score can be recomputed exactly
-- as reviews arrive (P6.3), and make existing (seeded) averages Bayesian too.

ALTER TABLE provider_profiles
    ADD COLUMN rating_sum NUMERIC(12, 2) NOT NULL DEFAULT 0;

-- Backfill the raw sum from the seeded average * count.
UPDATE provider_profiles
SET rating_sum = ROUND(avg_rating * rating_count, 2)
WHERE rating_count > 0;

-- Recompute the displayed average as a Bayesian score (prior 3.0, m 5) so all
-- providers are on the same, fairness-corrected scale.
UPDATE provider_profiles
SET avg_rating = ROUND(
        (rating_count::numeric / (rating_count + 5)) * avg_rating
        + (5.0 / (rating_count + 5)) * 3.0, 2)
WHERE rating_count > 0;
