-- Knowledge Hub articles (P9.1): help/guides for customers and providers.

CREATE TABLE articles (
    id               UUID PRIMARY KEY,
    slug             VARCHAR(160) NOT NULL UNIQUE,
    title            VARCHAR(200) NOT NULL,
    category         VARCHAR(60) NOT NULL,
    excerpt          VARCHAR(400) NOT NULL,
    content          TEXT NOT NULL,
    cover_image_url  VARCHAR(500),
    author_name      VARCHAR(120) NOT NULL,
    published        BOOLEAN NOT NULL DEFAULT FALSE,
    published_at     TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_articles_published ON articles (published, published_at DESC);
CREATE INDEX idx_articles_category ON articles (category);

-- Starter content so the hub isn't empty on first run.
INSERT INTO articles (id, slug, title, category, excerpt, content, author_name, published, published_at)
VALUES
(gen_random_uuid(), 'choosing-a-trusted-provider', 'How to choose a trusted provider',
 'For Customers',
 'Ratings, reviews and the verified badge — how to pick the right professional on GIGGO.',
 'Finding the right professional is easier when you know what to look for.\n\n'
 '1. Check the rating. GIGGO uses a fair, Bayesian rating that blends star ratings with the sentiment of written reviews, so a provider with a handful of reviews is not unfairly boosted over a proven one.\n\n'
 '2. Read recent reviews. The sentiment badge summarises how customers felt — look for consistency, not just a high number.\n\n'
 '3. Prefer the verified badge. Verified providers have completed identity checks (KYC).\n\n'
 '4. Compare the transparent price. Every booking shows a full breakdown — base fee, work fee and travel — before you confirm.',
 'GIGGO Team', TRUE, now()),
(gen_random_uuid(), 'how-payments-and-escrow-work', 'Payments & escrow: how it works',
 'For Customers',
 'Your money is held safely until the job is done. Here is the flow from booking to payout.',
 'GIGGO protects both sides with escrow.\n\n'
 'When you pay for a completed job, the money is held securely by GIGGO — not sent straight to the provider. Once you are happy with the work, you release it, and the provider is paid out minus a small platform fee.\n\n'
 'If something is wrong before you release, you can request a refund of the escrowed funds. This keeps payments fair and low-risk for everyone.',
 'GIGGO Team', TRUE, now()),
(gen_random_uuid(), 'staying-safe-with-home-services', 'Staying safe with home services',
 'Safety',
 'Simple steps to keep your home and details safe when booking a service.',
 'A few habits go a long way.\n\n'
 '• Share only what the provider needs. Your contact details are used for the job, not marketing.\n\n'
 '• Track arrival in-app. You can follow your provider on the way and see a live ETA.\n\n'
 '• Keep communication and payment on GIGGO, so everything is recorded and protected by escrow.\n\n'
 '• Leave an honest review afterwards — it helps the whole community.',
 'GIGGO Team', TRUE, now()),
(gen_random_uuid(), 'getting-verified-as-a-provider', 'Getting verified as a provider',
 'For Providers',
 'Earn the verified badge, win more trust, and get more bookings.',
 'Verified providers stand out and get chosen more often.\n\n'
 'Head to Profile → Verification and submit your ID document (NIC, passport or driving licence). Our team reviews it, and once approved the verified badge appears on your profile across GIGGO.\n\n'
 'Tips: use the exact name on your document, and make sure the number is entered correctly to avoid delays.',
 'GIGGO Team', TRUE, now());
