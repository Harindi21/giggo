package com.giggo.backend.knowledge.service;

import static org.assertj.core.api.Assertions.assertThat;
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
import org.springframework.test.util.ReflectionTestUtils;

import com.giggo.backend.knowledge.domain.Article;
import com.giggo.backend.knowledge.repository.ArticleRepository;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ArticleRecommendationService")
class ArticleRecommendationServiceTest {

    @Mock ArticleRepository articleRepository;
    @Mock ProviderProfileRepository providerRepository;

    private ArticleRecommendationService service;

    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new ArticleRecommendationService(articleRepository, providerRepository);
        ReflectionTestUtils.setField(service, "limit", 5);
    }

    private Article article(String title, String category, String excerpt, int views) {
        return Article.builder().id(UUID.randomUUID()).slug(title.toLowerCase().replace(' ', '-'))
                .title(title).category(category).excerpt(excerpt).content("body")
                .authorName("GIGGO Team").published(true).viewCount(views).build();
    }

    private ProviderProfile plumber() {
        Category plumbing = Category.builder().id(UUID.randomUUID()).name("Plumbing").active(true).build();
        Skill pipe = Skill.builder().id(UUID.randomUUID()).name("Pipe repair").active(true)
                .category(plumbing).build();
        ProviderProfile p = ProviderProfile.builder().id(UUID.randomUUID()).build();
        p.setSkills(java.util.Set.of(pipe));
        return p;
    }

    @Test
    @DisplayName("ranks profession-matching guides above more popular unrelated ones")
    void ranksByProfession() {
        Article plumbing = article("Plumbing safety tips", "Safety", "look after your pipes", 2);
        Article business = article("Growing your business", "Business", "marketing basics", 10);
        when(articleRepository.findByPublishedTrueOrderByPublishedAtDesc())
                .thenReturn(List.of(business, plumbing));
        when(providerRepository.findByUserId(userId)).thenReturn(Optional.of(plumber()));

        List<Article> out = service.recommendedFor(userId);

        assertThat(out).first().extracting(Article::getTitle).isEqualTo("Plumbing safety tips");
    }

    @Test
    @DisplayName("no profile -> most popular guides first")
    void fallsBackToPopular() {
        Article plumbing = article("Plumbing safety tips", "Safety", "pipes", 2);
        Article business = article("Growing your business", "Business", "marketing", 10);
        when(articleRepository.findByPublishedTrueOrderByPublishedAtDesc())
                .thenReturn(List.of(plumbing, business));
        when(providerRepository.findByUserId(userId)).thenReturn(Optional.empty());

        List<Article> out = service.recommendedFor(userId);

        assertThat(out).first().extracting(Article::getTitle).isEqualTo("Growing your business");
    }
}
