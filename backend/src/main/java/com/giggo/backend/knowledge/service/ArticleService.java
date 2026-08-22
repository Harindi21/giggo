package com.giggo.backend.knowledge.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.knowledge.api.dto.CreateArticleRequest;
import com.giggo.backend.knowledge.api.dto.UpdateArticleRequest;
import com.giggo.backend.knowledge.domain.Article;
import com.giggo.backend.knowledge.repository.ArticleRepository;

import lombok.RequiredArgsConstructor;

/** Knowledge Hub articles (P9.1). Public reads see only published articles. */
@Service
@RequiredArgsConstructor
public class ArticleService {

    private final ArticleRepository articleRepository;

    @Transactional(readOnly = true)
    public List<Article> listPublished(String category, String query) {
        if (query != null && !query.isBlank()) {
            List<Article> hits = articleRepository.searchPublished(query.trim());
            if (category == null || category.isBlank()) {
                return hits;
            }
            return hits.stream().filter(a -> category.trim().equalsIgnoreCase(a.getCategory())).toList();
        }
        if (category == null || category.isBlank()) {
            return articleRepository.findByPublishedTrueOrderByPublishedAtDesc();
        }
        return articleRepository
                .findByPublishedTrueAndCategoryOrderByPublishedAtDesc(category.trim());
    }

    @Transactional(readOnly = true)
    public Article getPublishedBySlug(String slug) {
        Article article = articleRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Article not found"));
        if (!article.isPublished()) {
            throw new ResourceNotFoundException("Article not found");
        }
        return article;
    }

    /** Increment the view count for a published article (P9.4). */
    @Transactional
    public Article recordView(String slug) {
        Article article = getPublishedBySlug(slug);
        article.setViewCount(article.getViewCount() + 1);
        return articleRepository.save(article);
    }

    /** Add a 1–5 helpfulness rating to a published article (P9.4). */
    @Transactional
    public Article rate(String slug, int rating) {
        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5.");
        }
        Article article = getPublishedBySlug(slug);
        article.setRatingSum(article.getRatingSum() + rating);
        article.setRatingCount(article.getRatingCount() + 1);
        return articleRepository.save(article);
    }

    @Transactional
    public Article create(CreateArticleRequest req) {
        if (articleRepository.existsBySlug(req.slug())) {
            throw new DuplicateResourceException("An article with this slug already exists");
        }
        Article article = Article.builder()
                .slug(req.slug())
                .title(req.title())
                .category(req.category())
                .excerpt(req.excerpt())
                .content(req.content())
                .coverImageUrl(req.coverImageUrl())
                .authorName(req.authorName() == null || req.authorName().isBlank()
                        ? "GIGGO Team" : req.authorName())
                .published(req.published())
                .publishedAt(req.published() ? OffsetDateTime.now() : null)
                .build();
        return articleRepository.save(article);
    }

    @Transactional
    public Article update(UUID id, UpdateArticleRequest req) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article not found"));
        if (req.title() != null) article.setTitle(req.title());
        if (req.category() != null) article.setCategory(req.category());
        if (req.excerpt() != null) article.setExcerpt(req.excerpt());
        if (req.content() != null) article.setContent(req.content());
        if (req.coverImageUrl() != null) article.setCoverImageUrl(req.coverImageUrl());
        if (req.authorName() != null) article.setAuthorName(req.authorName());
        if (req.published() != null) {
            article.setPublished(req.published());
            if (req.published() && article.getPublishedAt() == null) {
                article.setPublishedAt(OffsetDateTime.now());
            }
        }
        return articleRepository.save(article);
    }
}
