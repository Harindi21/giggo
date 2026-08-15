package com.giggo.backend.marketplace.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateToolRequest(
        @NotBlank @Size(max = 160) String slug,
        @NotBlank @Size(max = 200) String name,
        @NotBlank @Size(max = 60) String category,
        @Size(max = 120) String brand,
        @NotBlank @Size(max = 1000) String description,
        @NotNull @DecimalMin("0.0") BigDecimal price,
        @Size(max = 500) String imageUrl,
        boolean available
) {}
