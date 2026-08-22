package com.giggo.backend.marketplace.service;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.marketplace.api.dto.ToolResponse;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.domain.WishlistItem;
import com.giggo.backend.marketplace.repository.ToolRepository;
import com.giggo.backend.marketplace.repository.WishlistRepository;

import lombok.RequiredArgsConstructor;

/** Tool wishlist / save-for-later (P10.3). */
@Service
@RequiredArgsConstructor
public class WishlistService {

    private final WishlistRepository wishlistRepository;
    private final ToolRepository toolRepository;

    @Transactional
    public void add(UUID userId, UUID toolId) {
        if (!toolRepository.existsById(toolId)) {
            throw new ResourceNotFoundException("Tool not found");
        }
        if (!wishlistRepository.existsByUserIdAndToolId(userId, toolId)) {
            wishlistRepository.save(WishlistItem.builder().userId(userId).toolId(toolId).build());
        }
    }

    @Transactional
    public void remove(UUID userId, UUID toolId) {
        wishlistRepository.deleteByUserIdAndToolId(userId, toolId);
    }

    /** The user's saved tools, most-recently-saved first. */
    @Transactional(readOnly = true)
    public List<ToolResponse> list(UUID userId) {
        List<WishlistItem> items = wishlistRepository.findByUserIdOrderByCreatedAtDesc(userId);
        Map<UUID, Tool> byId = toolRepository
                .findAllById(items.stream().map(WishlistItem::getToolId).toList())
                .stream()
                .collect(Collectors.toMap(Tool::getId, Function.identity()));
        return items.stream()
                .map(i -> byId.get(i.getToolId()))
                .filter(Objects::nonNull)
                .map(ToolResponse::from)
                .toList();
    }
}
