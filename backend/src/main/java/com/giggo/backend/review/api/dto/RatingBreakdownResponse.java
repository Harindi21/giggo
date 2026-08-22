package com.giggo.backend.review.api.dto;

/** A provider's average ratings by dimension (P6.6); 0 when unrated. */
public record RatingBreakdownResponse(
        double service,
        double punctuality,
        double value,
        long count
) {}
