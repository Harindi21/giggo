package com.giggo.backend.marketplace.api.dto;

import java.math.BigDecimal;
import java.util.UUID;

import com.giggo.backend.marketplace.domain.Tool;

public record ToolResponse(
        UUID id,
        String slug,
        String name,
        String category,
        String brand,
        String description,
        BigDecimal price,
        String currency,
        String imageUrl,
        boolean available
) {
    public static ToolResponse from(Tool t) {
        return new ToolResponse(
                t.getId(), t.getSlug(), t.getName(), t.getCategory(), t.getBrand(),
                t.getDescription(), t.getPrice(), t.getCurrency(), t.getImageUrl(),
                t.isAvailable());
    }
}
