-- Review moderation (P6.5): soft-hide abusive/fake reviews and let users report
-- them. A hidden review is excluded from listings and the provider's rating.

ALTER TABLE reviews
    ADD COLUMN hidden           BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN moderation_reason VARCHAR(500),
    ADD COLUMN report_count     INT NOT NULL DEFAULT 0;

CREATE INDEX idx_reviews_reported ON reviews (report_count DESC) WHERE report_count > 0;
