package com.giggo.backend.provider.api.dto;

import java.util.List;
import java.util.UUID;

import com.giggo.backend.provider.domain.ProviderProfile;

public record ProviderProfileResponse(
        UUID id,
        UUID userId,
        String fullName,
        String bio,
        int yearsExperience,
        boolean available,
        List<SkillResponse> skills
) {
    public static ProviderProfileResponse from(ProviderProfile p) {
        return new ProviderProfileResponse(
                p.getId(),
                p.getUser().getId(),
                p.getUser().getFullName(),
                p.getBio(),
                p.getYearsExperience(),
                p.isAvailable(),
                p.getSkills().stream().map(SkillResponse::from).toList()
        );
    }
}