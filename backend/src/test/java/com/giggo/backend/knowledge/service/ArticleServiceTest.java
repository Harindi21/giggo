package com.giggo.backend.knowledge.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.knowledge.api.dto.CreateArticleRequest;
import com.giggo.backend.knowledge.domain.Article;
import com.giggo.backend.knowledge.repository.ArticleRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ArticleService")
class ArticleServiceTest {

    @Mock ArticleRepository articleRepository;

    private ArticleService service;

    @BeforeEach
    void setUp() {
        service = new ArticleService(articleRepository);
        lenient().when(articleRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private Article article(boolean published) {
        return Article.builder()
                .id(UUID.randomUUID())
                .slug("guide")
                .title("A guide")
                .category("Safety")
                .excerpt("x")
                .content("body")
                .authorName("GIGGO Team")
                .published(published)
                .build();
    }

    @Test
    @DisplayName("getPublishedBySlug returns a published article")
    void getPublishedReturns() {
        when(articleRepository.findBySlug("guide")).thenReturn(Optional.of(article(true)));
        assertThat(service.getPublishedBySlug("guide").getSlug()).isEqualTo("guide");
    }

    @Test
    @DisplayName("getPublishedBySlug hides unpublished articles")
    void getUnpublishedHidden() {
        when(articleRepository.findBySlug("guide")).thenReturn(Optional.of(article(false)));
        assertThatThrownBy(() -> service.getPublishedBySlug("guide"))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("create rejects a duplicate slug")
    void createRejectsDuplicate() {
        when(articleRepository.existsBySlug("guide")).thenReturn(true);
        var req = new CreateArticleRequest("guide", "T", "Safety", "e", "c", null, null, true);
        assertThatThrownBy(() -> service.create(req))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    @DisplayName("create publishes with a timestamp and default author")
    void createPublishes() {
        when(articleRepository.existsBySlug("new")).thenReturn(false);
        var req = new CreateArticleRequest("new", "T", "Safety", "e", "c", null, null, true);

        Article out = service.create(req);

        assertThat(out.isPublished()).isTrue();
        assertThat(out.getPublishedAt()).isNotNull();
        assertThat(out.getAuthorName()).isEqualTo("GIGGO Team");
    }

    @Test
    @DisplayName("listPublished filters by category when given")
    void listByCategory() {
        when(articleRepository.findByPublishedTrueAndCategoryOrderByPublishedAtDesc("Safety"))
                .thenReturn(List.of(article(true)));

        assertThat(service.listPublished("Safety", null)).hasSize(1);
        verify(articleRepository).findByPublishedTrueAndCategoryOrderByPublishedAtDesc("Safety");
    }

    @Test
    @DisplayName("listPublished searches when a query is given (P9.8)")
    void listBySearch() {
        when(articleRepository.searchPublished("pipe")).thenReturn(List.of(article(true)));

        assertThat(service.listPublished(null, "pipe")).hasSize(1);
        verify(articleRepository).searchPublished("pipe");
    }

    @Test
    @DisplayName("recordView increments the view count (P9.4)")
    void recordView() {
        when(articleRepository.findBySlug("guide")).thenReturn(Optional.of(article(true)));
        Article out = service.recordView("guide");
        assertThat(out.getViewCount()).isEqualTo(1);
    }

    @Test
    @DisplayName("rate accumulates the rating tally (P9.4)")
    void rate() {
        Article a = article(true);
        when(articleRepository.findBySlug("guide")).thenReturn(Optional.of(a));
        service.rate("guide", 4);
        service.rate("guide", 2);
        assertThat(a.getRatingSum()).isEqualTo(6);
        assertThat(a.getRatingCount()).isEqualTo(2);
    }

    @Test
    @DisplayName("rate rejects an out-of-range value")
    void rateRejectsBadValue() {
        // No stubbing needed: validation happens before any repository call.
        assertThatThrownBy(() -> service.rate("guide", 6))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
