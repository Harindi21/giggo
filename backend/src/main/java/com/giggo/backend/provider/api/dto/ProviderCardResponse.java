package com.giggo.backend.provider.api.dto;

import java.math.BigDecimal;
import java.util.UUID;

import com.giggo.backend.provider.domain.ProviderProfile;

/** Compact provider representation for search / list screens. */
public record ProviderCardResponse(
        UUID id,
        UUID userId,
        String fullName,
        String headline,
        String district,
        String avatarUrl,
        BigDecimal avgRating,
        int ratingCount,
        int jobsCompleted,
        BigDecimal basePrice,
        BigDecimal hourlyRate,
        boolean available,
        boolean verified,
        Double latitude,
        Double longitude
) {
    public static ProviderCardResponse from(ProviderProfile p) {
        return new ProviderCardResponse(
                p.getId(),
                p.getUser().getId(),
                p.getUser().getFullName(),
                p.getHeadline(),
                p.getDistrict(),
                p.getAvatarUrl(),
                p.getAvgRating(),
                p.getRatingCount(),
                p.getJobsCompleted(),
                p.getBasePrice(),
                p.getHourlyRate(),
                p.isAvailable(),
                p.isVerified(),
                p.getLatitude(),
                p.getLongitude()
        );
    }
}
