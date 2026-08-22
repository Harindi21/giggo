package com.giggo.backend.marketplace.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.marketplace.domain.WishlistItem;

public interface WishlistRepository extends JpaRepository<WishlistItem, UUID> {
    List<WishlistItem> findByUserIdOrderByCreatedAtDesc(UUID userId);
    boolean existsByUserIdAndToolId(UUID userId, UUID toolId);

    @Transactional
    void deleteByUserIdAndToolId(UUID userId, UUID toolId);
}
