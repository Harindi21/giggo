package com.giggo.backend.knowledge.api;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.knowledge.api.dto.ArticleResponse;
import com.giggo.backend.knowledge.api.dto.ArticleSummaryResponse;
import com.giggo.backend.knowledge.service.ArticleService;

import lombok.RequiredArgsConstructor;

/** Public Knowledge Hub reads (P9.1). */
@RestController
@RequestMapping("/api/v1/articles")
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleService articleService;

    @GetMapping
    public ApiResponse<List<ArticleSummaryResponse>> list(
            @RequestParam(required = false) String category) {
        return ApiResponse.ok(articleService.listPublished(category).stream()
                .map(ArticleSummaryResponse::from)
                .toList());
    }

    @GetMapping("/{slug}")
    public ApiResponse<ArticleResponse> get(@PathVariable String slug) {
        return ApiResponse.ok(ArticleResponse.from(articleService.getPublishedBySlug(slug)));
    }
}
