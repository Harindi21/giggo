package com.giggo.backend.knowledge.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giggo.backend.knowledge.domain.Article;

public interface ArticleRepository extends JpaRepository<Article, UUID> {
    List<Article> findByPublishedTrueOrderByPublishedAtDesc();
    List<Article> findByPublishedTrueAndCategoryOrderByPublishedAtDesc(String category);
    Optional<Article> findBySlug(String slug);
    boolean existsBySlug(String slug);

    /** Full-text-ish search over title / excerpt / content of published articles (P9.8). */
    @Query("""
            SELECT a FROM Article a
            WHERE a.published = true AND (
                LOWER(a.title) LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(a.excerpt) LIKE LOWER(CONCAT('%', :q, '%'))
                OR LOWER(a.content) LIKE LOWER(CONCAT('%', :q, '%')))
            ORDER BY a.publishedAt DESC
            """)
    List<Article> searchPublished(@Param("q") String q);
}
