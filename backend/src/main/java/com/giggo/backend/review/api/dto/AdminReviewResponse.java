package com.giggo.backend.review.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.review.domain.Review;

/** Review as seen in the admin moderation queue (P6.5). */
public record AdminReviewResponse(
        UUID id,
        UUID providerId,
        String reviewerName,
        int stars,
        String body,
        String sentimentLabel,
        boolean hidden,
        String moderationReason,
        int reportCount,
        OffsetDateTime createdAt
) {
    public static AdminReviewResponse from(Review r, String reviewerName) {
        return new AdminReviewResponse(
                r.getId(), r.getProviderId(), reviewerName, r.getStars(), r.getBody(),
                r.getSentimentLabel(), r.isHidden(), r.getModerationReason(),
                r.getReportCount(), r.getCreatedAt());
    }
}
