package com.giggo.backend.provider.api.dto;

import java.math.BigDecimal;
import java.util.Set;
import java.util.UUID;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

public record UpdateProviderProfileRequest(
        @Size(max = 1000) String bio,
        @Min(0) int yearsExperience,
        @Size(max = 150) String headline,
        @Size(max = 100) String district,
        @Size(max = 255) String addressLine,
        Double latitude,
        Double longitude,
        @DecimalMin("0.0") BigDecimal basePrice,
        @DecimalMin("0.0") BigDecimal hourlyRate,
        Boolean available,
        Set<UUID> skillIds
) {}
