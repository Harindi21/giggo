package com.giggo.backend.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.payment.api.dto.CommissionResponse;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.CategoryRepository;
import com.giggo.backend.provider.repository.SkillRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("CommissionService")
class CommissionServiceTest {

    @Mock SkillRepository skillRepository;
    @Mock CategoryRepository categoryRepository;

    private CommissionService service;

    private final UUID skillId = UUID.randomUUID();
    private final UUID categoryId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new CommissionService(skillRepository, categoryRepository, new BigDecimal("0.10"));
    }

    private Skill skillWith(BigDecimal categoryRate) {
        Category category = Category.builder()
                .id(categoryId).name("Plumbing").active(true).commissionRate(categoryRate).build();
        return Skill.builder().id(skillId).name("Pipe repair").active(true).category(category).build();
    }

    @Test
    @DisplayName("uses the category override when set")
    void categoryOverride() {
        when(skillRepository.findById(skillId)).thenReturn(Optional.of(skillWith(new BigDecimal("0.15"))));
        assertThat(service.rateForSkill(skillId)).isEqualByComparingTo("0.15");
    }

    @Test
    @DisplayName("falls back to the platform default when no override")
    void fallsBackToDefault() {
        when(skillRepository.findById(skillId)).thenReturn(Optional.of(skillWith(null)));
        assertThat(service.rateForSkill(skillId)).isEqualByComparingTo("0.10");
    }

    @Test
    @DisplayName("unknown skill uses the default")
    void unknownSkill() {
        when(skillRepository.findById(skillId)).thenReturn(Optional.empty());
        assertThat(service.rateForSkill(skillId)).isEqualByComparingTo("0.10");
    }

    @Test
    @DisplayName("setRate stores the override; list flags default vs override")
    void setAndList() {
        Category category = Category.builder().id(categoryId).name("Plumbing").active(true).build();
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(category));
        when(categoryRepository.save(category)).thenAnswer(i -> i.getArgument(0));

        CommissionResponse set = service.setRate(categoryId, new BigDecimal("0.18"));
        assertThat(set.rate()).isEqualByComparingTo("0.18");
        assertThat(set.usingDefault()).isFalse();

        when(categoryRepository.findByActiveTrue()).thenReturn(List.of(category));
        List<CommissionResponse> list = service.list();
        assertThat(list).singleElement().satisfies(c -> {
            assertThat(c.rate()).isEqualByComparingTo("0.18");
            assertThat(c.usingDefault()).isFalse();
        });
    }

    @Test
    @DisplayName("clearRate reverts to the default")
    void clearRate() {
        Category category = Category.builder()
                .id(categoryId).name("Plumbing").active(true).commissionRate(new BigDecimal("0.20")).build();
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(category));
        when(categoryRepository.save(category)).thenAnswer(i -> i.getArgument(0));

        CommissionResponse cleared = service.clearRate(categoryId);
        assertThat(cleared.usingDefault()).isTrue();
        assertThat(cleared.rate()).isEqualByComparingTo("0.10");
    }
}
