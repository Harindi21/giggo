package com.giggo.backend.knowledge.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.knowledge.domain.Article;

/** Compact article for list screens (no body). */
public record ArticleSummaryResponse(
        UUID id,
        String slug,
        String title,
        String category,
        String excerpt,
        String coverImageUrl,
        String authorName,
        OffsetDateTime publishedAt,
        int viewCount,
        double avgRating,
        int ratingCount
) {
    public static ArticleSummaryResponse from(Article a) {
        return new ArticleSummaryResponse(
                a.getId(), a.getSlug(), a.getTitle(), a.getCategory(), a.getExcerpt(),
                a.getCoverImageUrl(), a.getAuthorName(), a.getPublishedAt(),
                a.getViewCount(), ArticleResponse.avg(a), a.getRatingCount());
    }
}
