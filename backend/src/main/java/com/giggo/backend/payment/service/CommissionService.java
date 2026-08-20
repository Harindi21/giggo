package com.giggo.backend.payment.service;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.payment.api.dto.CommissionResponse;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.CategoryRepository;
import com.giggo.backend.provider.repository.SkillRepository;

/**
 * Resolves the platform commission rate for a booking (P7.7). Each category may
 * carry an override; a booking's rate is its skill's category rate, or the flat
 * platform default when no override is set. Also backs the admin config (P11.8).
 */
@Service
public class CommissionService {

    private final SkillRepository skillRepository;
    private final CategoryRepository categoryRepository;
    private final BigDecimal defaultRate;

    public CommissionService(
            SkillRepository skillRepository,
            CategoryRepository categoryRepository,
            @Value("${giggo.payments.commission-rate:0.10}") BigDecimal defaultRate) {
        this.skillRepository = skillRepository;
        this.categoryRepository = categoryRepository;
        this.defaultRate = defaultRate;
    }

    /** The effective commission rate for a booking of {@code skillId}. */
    @Transactional(readOnly = true)
    public BigDecimal rateForSkill(UUID skillId) {
        return skillRepository.findById(skillId)
                .map(Skill::getCategory)
                .map(Category::getCommissionRate)
                .orElse(defaultRate);
    }

    public BigDecimal defaultRate() {
        return defaultRate;
    }

    // ---- Admin config (P11.8) ----

    @Transactional(readOnly = true)
    public List<CommissionResponse> list() {
        return categoryRepository.findByActiveTrue().stream()
                .sorted(Comparator.comparing(Category::getName))
                .map(this::toResponse)
                .toList();
    }

    /** Set a category's commission override (0..1). */
    @Transactional
    public CommissionResponse setRate(UUID categoryId, BigDecimal rate) {
        Category category = category(categoryId);
        category.setCommissionRate(rate);
        return toResponse(categoryRepository.save(category));
    }

    /** Clear a category's override so it reverts to the platform default. */
    @Transactional
    public CommissionResponse clearRate(UUID categoryId) {
        Category category = category(categoryId);
        category.setCommissionRate(null);
        return toResponse(categoryRepository.save(category));
    }

    private Category category(UUID categoryId) {
        return categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
    }

    private CommissionResponse toResponse(Category c) {
        boolean usingDefault = c.getCommissionRate() == null;
        BigDecimal rate = usingDefault ? defaultRate : c.getCommissionRate();
        return new CommissionResponse(c.getId(), c.getName(), rate, usingDefault);
    }
}
