package com.giggo.backend.provider.api.dto;

import java.util.UUID;

import com.giggo.backend.provider.domain.Category;

public record CategoryResponse(UUID id, String name, String description, boolean active) {
    public static CategoryResponse from(Category c) {
        return new CategoryResponse(c.getId(), c.getName(), c.getDescription(), c.isActive());
    }
}