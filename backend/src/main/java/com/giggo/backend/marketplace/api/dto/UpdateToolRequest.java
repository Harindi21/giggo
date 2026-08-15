package com.giggo.backend.marketplace.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;

/** Partial update: only non-null fields are applied. */
public record UpdateToolRequest(
        @Size(max = 200) String name,
        @Size(max = 60) String category,
        @Size(max = 120) String brand,
        @Size(max = 1000) String description,
        @DecimalMin("0.0") BigDecimal price,
        @Size(max = 500) String imageUrl,
        Boolean available
) {}
