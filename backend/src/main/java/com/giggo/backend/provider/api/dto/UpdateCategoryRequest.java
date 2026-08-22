package com.giggo.backend.provider.api.dto;

import jakarta.validation.constraints.Size;

/** Admin edit of a category (P11.5). All fields optional; null leaves a field unchanged. */
public record UpdateCategoryRequest(
        @Size(max = 100) String name,
        @Size(max = 500) String description,
        Boolean active
) {}
