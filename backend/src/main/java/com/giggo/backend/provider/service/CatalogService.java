package com.giggo.backend.provider.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.api.dto.CategoryResponse;
import com.giggo.backend.provider.api.dto.CreateCategoryRequest;
import com.giggo.backend.provider.api.dto.CreateSkillRequest;
import com.giggo.backend.provider.api.dto.SkillResponse;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.CategoryRepository;
import com.giggo.backend.provider.repository.SkillRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CatalogService {

    private final CategoryRepository categoryRepository;
    private final SkillRepository skillRepository;

    @Transactional
    public CategoryResponse createCategory(CreateCategoryRequest req) {
        if (categoryRepository.existsByNameIgnoreCase(req.name().trim())) {
            throw new DuplicateResourceException("A category with this name already exists");
        }
        Category c = Category.builder()
                .name(req.name().trim())
                .description(req.description())
                .active(true)
                .build();
        return CategoryResponse.from(categoryRepository.save(c));
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> listCategories() {
        return categoryRepository.findByActiveTrue().stream()
                .map(CategoryResponse::from).toList();
    }

    @Transactional
    public SkillResponse createSkill(CreateSkillRequest req) {
        Category category = categoryRepository.findById(req.categoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        if (skillRepository.existsByCategoryIdAndNameIgnoreCase(category.getId(), req.name().trim())) {
            throw new DuplicateResourceException("This skill already exists in the category");
        }
        Skill s = Skill.builder()
                .category(category)
                .name(req.name().trim())
                .active(true)
                .build();
        return SkillResponse.from(skillRepository.save(s));
    }

    @Transactional(readOnly = true)
    public List<SkillResponse> listSkillsByCategory(UUID categoryId) {
        return skillRepository.findByCategoryIdAndActiveTrue(categoryId).stream()
                .map(SkillResponse::from).toList();
    }
}