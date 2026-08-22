package com.giggo.backend.provider.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
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

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.api.dto.CategoryResponse;
import com.giggo.backend.provider.api.dto.UpdateCategoryRequest;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.repository.CategoryRepository;
import com.giggo.backend.provider.repository.SkillRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("CatalogService")
class CatalogServiceTest {

    @Mock CategoryRepository categoryRepository;
    @Mock SkillRepository skillRepository;

    private CatalogService service;

    private final UUID categoryId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new CatalogService(categoryRepository, skillRepository);
        lenient().when(categoryRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private Category category() {
        return Category.builder().id(categoryId).name("Plumbing")
                .description("old").active(true).build();
    }

    @Test
    @DisplayName("updateCategory edits fields and can deactivate")
    void updateCategory() {
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(category()));

        CategoryResponse out = service.updateCategory(categoryId,
                new UpdateCategoryRequest("Plumbing & Pipes", "new desc", false));

        assertThat(out.name()).isEqualTo("Plumbing & Pipes");
        assertThat(out.description()).isEqualTo("new desc");
        assertThat(out.active()).isFalse();
    }

    @Test
    @DisplayName("updateCategory leaves null fields unchanged")
    void updatePartial() {
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.of(category()));

        CategoryResponse out = service.updateCategory(categoryId,
                new UpdateCategoryRequest(null, null, null));

        assertThat(out.name()).isEqualTo("Plumbing");
        assertThat(out.description()).isEqualTo("old");
        assertThat(out.active()).isTrue();
    }

    @Test
    @DisplayName("updateCategory on an unknown id -> 404")
    void updateUnknown() {
        when(categoryRepository.findById(categoryId)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.updateCategory(categoryId,
                new UpdateCategoryRequest("x", null, null)))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("listAllCategories includes deactivated ones")
    void listAll() {
        Category inactive = Category.builder().id(UUID.randomUUID()).name("Old").active(false).build();
        when(categoryRepository.findAll()).thenReturn(List.of(category(), inactive));

        List<CategoryResponse> all = service.listAllCategories();

        assertThat(all).hasSize(2);
        assertThat(all).anyMatch(c -> !c.active());
    }
}
