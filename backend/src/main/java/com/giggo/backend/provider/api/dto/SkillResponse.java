package com.giggo.backend.provider.api.dto;

import java.util.UUID;

import com.giggo.backend.provider.domain.Skill;

public record SkillResponse(UUID id, UUID categoryId, String name) {
    public static SkillResponse from(Skill s) {
        return new SkillResponse(s.getId(), s.getCategory().getId(), s.getName());
    }
}