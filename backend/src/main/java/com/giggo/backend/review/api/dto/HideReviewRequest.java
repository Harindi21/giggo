package com.giggo.backend.review.api.dto;

import jakarta.validation.constraints.Size;

/** Optional reason when an admin hides a review. */
public record HideReviewRequest(@Size(max = 500) String reason) {}
