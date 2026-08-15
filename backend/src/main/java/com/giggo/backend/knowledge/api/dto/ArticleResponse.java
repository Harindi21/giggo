package com.giggo.backend.knowledge.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.knowledge.domain.Article;

/** Full article for the detail screen. */
public record ArticleResponse(
        UUID id,
        String slug,
        String title,
        String category,
        String excerpt,
        String content,
        String coverImageUrl,
        String authorName,
        boolean published,
        OffsetDateTime publishedAt
) {
    public static ArticleResponse from(Article a) {
        return new ArticleResponse(
                a.getId(), a.getSlug(), a.getTitle(), a.getCategory(), a.getExcerpt(),
                a.getContent(), a.getCoverImageUrl(), a.getAuthorName(),
                a.isPublished(), a.getPublishedAt());
    }
}
