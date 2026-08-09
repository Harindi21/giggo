package com.giggo.backend.provider.api.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import com.giggo.backend.provider.domain.ProviderProfile;

/** Full provider representation for the provider detail screen. */
public record ProviderDetailResponse(
        UUID id,
        UUID userId,
        String fullName,
        String headline,
        String bio,
        int yearsExperience,
        String district,
        String addressLine,
        Double latitude,
        Double longitude,
        String avatarUrl,
        BigDecimal avgRating,
        int ratingCount,
        int jobsCompleted,
        BigDecimal basePrice,
        BigDecimal hourlyRate,
        boolean available,
        boolean verified,
        List<SkillResponse> skills
) {
    public static ProviderDetailResponse from(ProviderProfile p) {
        return new ProviderDetailResponse(
                p.getId(),
                p.getUser().getId(),
                p.getUser().getFullName(),
                p.getHeadline(),
                p.getBio(),
                p.getYearsExperience(),
                p.getDistrict(),
                p.getAddressLine(),
                p.getLatitude(),
                p.getLongitude(),
                p.getAvatarUrl(),
                p.getAvgRating(),
                p.getRatingCount(),
                p.getJobsCompleted(),
                p.getBasePrice(),
                p.getHourlyRate(),
                p.isAvailable(),
                p.isVerified(),
                p.getSkills().stream()
                        .sorted((a, b) -> a.getName().compareToIgnoreCase(b.getName()))
                        .map(SkillResponse::from).toList()
        );
    }
}
