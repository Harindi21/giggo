package com.giggo.backend.provider.api.dto;

import java.util.Set;
import java.util.UUID;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

public record UpdateProviderProfileRequest(
        @Size(max = 1000) String bio,
        @Min(0) int yearsExperience,
        Set<UUID> skillIds
) {}