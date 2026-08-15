package com.giggo.backend.marketplace.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.marketplace.domain.Tool;

public interface ToolRepository extends JpaRepository<Tool, UUID> {
    List<Tool> findByAvailableTrueOrderByNameAsc();
    List<Tool> findByAvailableTrueAndCategoryOrderByNameAsc(String category);
    Optional<Tool> findBySlug(String slug);
    boolean existsBySlug(String slug);
}
