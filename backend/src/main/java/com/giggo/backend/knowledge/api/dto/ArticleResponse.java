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
        OffsetDateTime publishedAt,
        int viewCount,
        double avgRating,
        int ratingCount
) {
    public static ArticleResponse from(Article a) {
        return new ArticleResponse(
                a.getId(), a.getSlug(), a.getTitle(), a.getCategory(), a.getExcerpt(),
                a.getContent(), a.getCoverImageUrl(), a.getAuthorName(),
                a.isPublished(), a.getPublishedAt(),
                a.getViewCount(), avg(a), a.getRatingCount());
    }

    /** Average helpfulness rating (0 when unrated), one decimal. */
    static double avg(Article a) {
        if (a.getRatingCount() == 0) {
            return 0.0;
        }
        return Math.round((double) a.getRatingSum() / a.getRatingCount() * 10.0) / 10.0;
    }
}
