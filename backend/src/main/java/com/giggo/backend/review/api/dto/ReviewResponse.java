package com.giggo.backend.review.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.review.domain.Review;

public record ReviewResponse(
        UUID id,
        UUID bookingId,
        UUID customerId,
        String reviewerName,
        UUID providerId,
        int stars,
        String body,
        String sentimentLabel,
        BigDecimal sentimentScore,
        Integer sentimentStar,
        String sentimentEmotion,
        String sentimentLanguage,
        BigDecimal enhancedRating,
        OffsetDateTime createdAt
) {
    public static ReviewResponse from(Review r, String reviewerName) {
        return new ReviewResponse(
                r.getId(), r.getBookingId(), r.getCustomerId(), reviewerName, r.getProviderId(),
                r.getStars(), r.getBody(),
                r.getSentimentLabel(), r.getSentimentScore(), r.getSentimentStar(),
                r.getSentimentEmotion(), r.getSentimentLanguage(), r.getEnhancedRating(),
                r.getCreatedAt());
    }
}
