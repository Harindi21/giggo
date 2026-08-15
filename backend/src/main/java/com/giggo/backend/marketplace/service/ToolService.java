package com.giggo.backend.marketplace.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.marketplace.api.dto.CreateToolRequest;
import com.giggo.backend.marketplace.api.dto.UpdateToolRequest;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.repository.ToolRepository;

import lombok.RequiredArgsConstructor;

/** Tool Marketplace catalog (P10.1). Public reads see only available tools. */
@Service
@RequiredArgsConstructor
public class ToolService {

    private final ToolRepository toolRepository;

    @Transactional(readOnly = true)
    public List<Tool> listAvailable(String category) {
        if (category == null || category.isBlank()) {
            return toolRepository.findByAvailableTrueOrderByNameAsc();
        }
        return toolRepository.findByAvailableTrueAndCategoryOrderByNameAsc(category.trim());
    }

    @Transactional(readOnly = true)
    public Tool getBySlug(String slug) {
        return toolRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Tool not found"));
    }

    @Transactional
    public Tool create(CreateToolRequest req) {
        if (toolRepository.existsBySlug(req.slug())) {
            throw new DuplicateResourceException("A tool with this slug already exists");
        }
        Tool tool = Tool.builder()
                .slug(req.slug())
                .name(req.name())
                .category(req.category())
                .brand(req.brand())
                .description(req.description())
                .price(req.price())
                .currency("LKR")
                .imageUrl(req.imageUrl())
                .available(req.available())
                .build();
        return toolRepository.save(tool);
    }

    @Transactional
    public Tool update(UUID id, UpdateToolRequest req) {
        Tool tool = toolRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tool not found"));
        if (req.name() != null) tool.setName(req.name());
        if (req.category() != null) tool.setCategory(req.category());
        if (req.brand() != null) tool.setBrand(req.brand());
        if (req.description() != null) tool.setDescription(req.description());
        if (req.price() != null) tool.setPrice(req.price());
        if (req.imageUrl() != null) tool.setImageUrl(req.imageUrl());
        if (req.available() != null) tool.setAvailable(req.available());
        return toolRepository.save(tool);
    }
}
