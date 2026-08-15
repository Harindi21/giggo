package com.giggo.backend.marketplace.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
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

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.marketplace.api.dto.CreateToolRequest;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.repository.ToolRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ToolService")
class ToolServiceTest {

    @Mock ToolRepository toolRepository;

    private ToolService service;

    @BeforeEach
    void setUp() {
        service = new ToolService(toolRepository);
        lenient().when(toolRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private Tool tool() {
        return Tool.builder()
                .id(UUID.randomUUID())
                .slug("drill")
                .name("Drill")
                .category("Power Tools")
                .description("A drill")
                .price(new BigDecimal("12500.00"))
                .available(true)
                .build();
    }

    @Test
    @DisplayName("getBySlug returns the tool")
    void getBySlug() {
        when(toolRepository.findBySlug("drill")).thenReturn(Optional.of(tool()));
        assertThat(service.getBySlug("drill").getName()).isEqualTo("Drill");
    }

    @Test
    @DisplayName("getBySlug throws when missing")
    void getBySlugMissing() {
        when(toolRepository.findBySlug("nope")).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.getBySlug("nope"))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("create rejects a duplicate slug")
    void createRejectsDuplicate() {
        when(toolRepository.existsBySlug("drill")).thenReturn(true);
        var req = new CreateToolRequest(
                "drill", "Drill", "Power Tools", "Bosch", "desc",
                new BigDecimal("100"), null, true);
        assertThatThrownBy(() -> service.create(req))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    @DisplayName("create saves a new tool in LKR")
    void createSaves() {
        when(toolRepository.existsBySlug("ladder")).thenReturn(false);
        var req = new CreateToolRequest(
                "ladder", "Ladder", "Access", null, "desc",
                new BigDecimal("9800"), null, true);

        Tool out = service.create(req);

        assertThat(out.getSlug()).isEqualTo("ladder");
        assertThat(out.getCurrency()).isEqualTo("LKR");
    }

    @Test
    @DisplayName("listAvailable filters by category when given")
    void listByCategory() {
        when(toolRepository.findByAvailableTrueAndCategoryOrderByNameAsc("Access"))
                .thenReturn(List.of(tool()));

        assertThat(service.listAvailable("Access")).hasSize(1);
        verify(toolRepository).findByAvailableTrueAndCategoryOrderByNameAsc("Access");
    }
}
