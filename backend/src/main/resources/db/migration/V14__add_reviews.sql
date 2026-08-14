-- Customer reviews of a provider for a completed job (P6.1). One review per booking.
-- Sentiment columns are filled from the NLP microservice (P6.2); enhanced_rating
-- blends the star rating with the text sentiment.

CREATE TABLE reviews (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id           UUID NOT NULL UNIQUE REFERENCES bookings (id) ON DELETE CASCADE,
    customer_id          UUID NOT NULL REFERENCES users (id),
    provider_id          UUID NOT NULL REFERENCES users (id),
    stars                INT  NOT NULL CHECK (stars BETWEEN 1 AND 5),
    body                 VARCHAR(2000),

    sentiment_label      VARCHAR(20),
    sentiment_score      NUMERIC(4, 3),
    sentiment_star       INT,
    sentiment_confidence NUMERIC(4, 3),
    sentiment_emotion    VARCHAR(30),
    sentiment_language   VARCHAR(10),
    enhanced_rating      NUMERIC(4, 2),

    created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reviews_provider ON reviews (provider_id, created_at DESC);
