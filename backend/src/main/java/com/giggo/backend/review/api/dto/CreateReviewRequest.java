package com.giggo.backend.review.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

/**
 * A review submission. {@code stars} is the overall rating; the three dimension
 * ratings (service, punctuality, value) are optional (P6.6).
 */
public record CreateReviewRequest(
        @Min(1) @Max(5) int stars,
        @Size(max = 2000) String body,
        @Min(1) @Max(5) Integer serviceRating,
        @Min(1) @Max(5) Integer punctualityRating,
        @Min(1) @Max(5) Integer valueRating
) {
    /** Overall-only convenience (keeps existing callers/tests working). */
    public CreateReviewRequest(int stars, String body) {
        this(stars, body, null, null, null);
    }
}
