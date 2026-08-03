package com.giggo.backend.provider.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.provider.domain.Skill;

public interface SkillRepository extends JpaRepository<Skill, UUID> {
    List<Skill> findByCategoryIdAndActiveTrue(UUID categoryId);
    boolean existsByCategoryIdAndNameIgnoreCase(UUID categoryId, String name);
}