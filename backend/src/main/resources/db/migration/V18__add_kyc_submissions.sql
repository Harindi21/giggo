-- Provider KYC verification (P2.2). One submission per provider; approval sets
-- provider_profiles.verified = true.

CREATE TABLE kyc_submissions (
    id                  UUID PRIMARY KEY,
    provider_user_id    UUID NOT NULL UNIQUE,
    full_name           VARCHAR(150) NOT NULL,
    document_type       VARCHAR(30) NOT NULL,
    document_number     VARCHAR(60) NOT NULL,
    document_image_url  VARCHAR(500),
    status              VARCHAR(20) NOT NULL,
    reviewed_by         UUID,
    review_note         VARCHAR(500),
    submitted_at        TIMESTAMPTZ NOT NULL,
    reviewed_at         TIMESTAMPTZ
);

CREATE INDEX idx_kyc_status ON kyc_submissions (status);
