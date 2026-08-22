package com.giggo.backend.review.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A customer's rating + review for a completed booking, enriched with NLP sentiment. */
@Entity
@Table(name = "reviews")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Review {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "booking_id", nullable = false, unique = true)
    private UUID bookingId;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "provider_id", nullable = false)
    private UUID providerId;

    @Column(name = "stars", nullable = false)
    private int stars;

    // ---- optional dimension ratings (P6.6) ----
    @Column(name = "service_rating")
    private Integer serviceRating;

    @Column(name = "punctuality_rating")
    private Integer punctualityRating;

    @Column(name = "value_rating")
    private Integer valueRating;

    @Column(name = "body", length = 2000)
    private String body;

    // ---- sentiment (from the NLP microservice, P6.2) ----
    @Column(name = "sentiment_label", length = 20)
    private String sentimentLabel;

    @Column(name = "sentiment_score")
    private BigDecimal sentimentScore;

    @Column(name = "sentiment_star")
    private Integer sentimentStar;

    @Column(name = "sentiment_confidence")
    private BigDecimal sentimentConfidence;

    @Column(name = "sentiment_emotion", length = 30)
    private String sentimentEmotion;

    @Column(name = "sentiment_language", length = 10)
    private String sentimentLanguage;

    /** Star rating blended with the text sentiment (thesis enhanced rating). */
    @Column(name = "enhanced_rating")
    private BigDecimal enhancedRating;

    // ---- moderation (P6.5) ----
    /** Hidden by an admin: excluded from listings and the provider aggregate. */
    @Column(name = "hidden", nullable = false)
    @Builder.Default
    private boolean hidden = false;

    @Column(name = "moderation_reason", length = 500)
    private String moderationReason;

    /** How many users have reported this review. */
    @Column(name = "report_count", nullable = false)
    @Builder.Default
    private int reportCount = 0;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = OffsetDateTime.now();
    }
}
