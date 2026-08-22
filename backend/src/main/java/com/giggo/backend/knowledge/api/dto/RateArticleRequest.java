package com.giggo.backend.knowledge.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

/** A helpfulness rating (1–5) for an article (P9.4). */
public record RateArticleRequest(
        @Min(1) @Max(5) int rating
) {}
