package com.giggo.backend.knowledge.api.dto;

import jakarta.validation.constraints.Size;

/** Partial update: only non-null fields are applied. */
public record UpdateArticleRequest(
        @Size(max = 200) String title,
        @Size(max = 60) String category,
        @Size(max = 400) String excerpt,
        String content,
        @Size(max = 500) String coverImageUrl,
        @Size(max = 120) String authorName,
        Boolean published
) {}
