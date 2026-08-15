package com.giggo.backend.knowledge.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateArticleRequest(
        @NotBlank @Size(max = 160) String slug,
        @NotBlank @Size(max = 200) String title,
        @NotBlank @Size(max = 60) String category,
        @NotBlank @Size(max = 400) String excerpt,
        @NotBlank String content,
        @Size(max = 500) String coverImageUrl,
        @Size(max = 120) String authorName,
        boolean published
) {}
