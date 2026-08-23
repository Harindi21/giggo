package com.giggo.backend.knowledge.api;

import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.knowledge.api.dto.ArticleResponse;
import com.giggo.backend.knowledge.api.dto.ArticleSummaryResponse;
import com.giggo.backend.knowledge.api.dto.RateArticleRequest;
import com.giggo.backend.knowledge.service.ArticleRecommendationService;
import com.giggo.backend.knowledge.service.ArticleService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Public Knowledge Hub reads (P9.1) + search/metrics/recommendations (P9.3, P9.4, P9.8). */
@RestController
@RequestMapping("/api/v1/articles")
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleService articleService;
    private final ArticleRecommendationService recommendationService;

    @GetMapping
    public ApiResponse<List<ArticleSummaryResponse>> list(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String q) {
        return ApiResponse.ok(articleService.listPublished(category, q).stream()
                .map(ArticleSummaryResponse::from)
                .toList());
    }

    /** "Recommended for you" guides, matched to the signed-in provider's skills (P9.3). */
    @GetMapping("/recommended")
    public ApiResponse<List<ArticleSummaryResponse>> recommended(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(recommendationService.recommendedFor(user.getId()).stream()
                .map(ArticleSummaryResponse::from)
                .toList());
    }

    @GetMapping("/{slug}")
    public ApiResponse<ArticleResponse> get(@PathVariable String slug) {
        return ApiResponse.ok(ArticleResponse.from(articleService.getPublishedBySlug(slug)));
    }

    /** Record a view (P9.4). */
    @PostMapping("/{slug}/view")
    public ApiResponse<ArticleResponse> view(@PathVariable String slug) {
        return ApiResponse.ok(ArticleResponse.from(articleService.recordView(slug)));
    }

    /** Rate an article's helpfulness 1–5 (P9.4). */
    @PostMapping("/{slug}/rate")
    public ApiResponse<ArticleResponse> rate(
            @PathVariable String slug, @Valid @RequestBody RateArticleRequest req) {
        return ApiResponse.ok(ArticleResponse.from(articleService.rate(slug, req.rating())));
    }
}
