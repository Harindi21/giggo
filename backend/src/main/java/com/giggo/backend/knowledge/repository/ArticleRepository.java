package com.giggo.backend.knowledge.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.knowledge.domain.Article;

public interface ArticleRepository extends JpaRepository<Article, UUID> {
    List<Article> findByPublishedTrueOrderByPublishedAtDesc();
    List<Article> findByPublishedTrueAndCategoryOrderByPublishedAtDesc(String category);
    Optional<Article> findBySlug(String slug);
    boolean existsBySlug(String slug);
}
