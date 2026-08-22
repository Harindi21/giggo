package com.giggo.backend.marketplace.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.marketplace.api.dto.ToolResponse;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.domain.WishlistItem;
import com.giggo.backend.marketplace.repository.ToolRepository;
import com.giggo.backend.marketplace.repository.WishlistRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("WishlistService")
class WishlistServiceTest {

    @Mock WishlistRepository wishlistRepository;
    @Mock ToolRepository toolRepository;

    private WishlistService service;

    private final UUID userId = UUID.randomUUID();
    private final UUID toolId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new WishlistService(wishlistRepository, toolRepository);
    }

    @Test
    @DisplayName("add saves once and is idempotent")
    void addIdempotent() {
        when(toolRepository.existsById(toolId)).thenReturn(true);
        when(wishlistRepository.existsByUserIdAndToolId(userId, toolId)).thenReturn(false);
        service.add(userId, toolId);
        verify(wishlistRepository).save(any());

        when(wishlistRepository.existsByUserIdAndToolId(userId, toolId)).thenReturn(true);
        service.add(userId, toolId);
        verify(wishlistRepository).save(any()); // still only the first save
    }

    @Test
    @DisplayName("add rejects an unknown tool")
    void addUnknownTool() {
        when(toolRepository.existsById(toolId)).thenReturn(false);
        assertThatThrownBy(() -> service.add(userId, toolId))
                .isInstanceOf(ResourceNotFoundException.class);
        verify(wishlistRepository, never()).save(any());
    }

    @Test
    @DisplayName("list returns the saved tools in wishlist order")
    void listInOrder() {
        UUID t1 = UUID.randomUUID();
        UUID t2 = UUID.randomUUID();
        when(wishlistRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(List.of(
                WishlistItem.builder().userId(userId).toolId(t1).build(),
                WishlistItem.builder().userId(userId).toolId(t2).build()));
        when(toolRepository.findAllById(List.of(t1, t2))).thenReturn(List.of(
                tool(t2, "Drill"), tool(t1, "Ladder"))); // repo returns any order

        List<ToolResponse> out = service.list(userId);

        assertThat(out).extracting(ToolResponse::name).containsExactly("Ladder", "Drill");
    }

    private Tool tool(UUID id, String name) {
        return Tool.builder().id(id).slug(name.toLowerCase()).name(name)
                .price(new BigDecimal("1000")).currency("LKR").available(true).build();
    }
}
