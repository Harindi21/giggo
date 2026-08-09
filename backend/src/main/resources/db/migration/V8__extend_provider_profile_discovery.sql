-- Discovery, pricing, location and rating fields for provider profiles.
-- Enables service search, dynamic pricing (base + travel + working) and
-- Bayesian rating display on provider cards / detail screens.

ALTER TABLE provider_profiles
    ADD COLUMN headline        VARCHAR(150),
    ADD COLUMN district        VARCHAR(100),
    ADD COLUMN address_line    VARCHAR(255),
    ADD COLUMN latitude        DOUBLE PRECISION,
    ADD COLUMN longitude       DOUBLE PRECISION,
    ADD COLUMN base_price      NUMERIC(10, 2) NOT NULL DEFAULT 0,
    ADD COLUMN hourly_rate     NUMERIC(10, 2) NOT NULL DEFAULT 0,
    -- Bayesian composite rating (0 = no reviews yet). Denormalised for fast list rendering.
    ADD COLUMN avg_rating      NUMERIC(3, 2)  NOT NULL DEFAULT 0,
    ADD COLUMN rating_count    INT            NOT NULL DEFAULT 0,
    ADD COLUMN jobs_completed  INT            NOT NULL DEFAULT 0,
    ADD COLUMN verified        BOOLEAN        NOT NULL DEFAULT FALSE,
    ADD COLUMN avatar_url      VARCHAR(500);

-- Search/sort helpers
CREATE INDEX idx_provider_district   ON provider_profiles (district);
CREATE INDEX idx_provider_avg_rating ON provider_profiles (avg_rating DESC);
CREATE INDEX idx_provider_available  ON provider_profiles (available);
