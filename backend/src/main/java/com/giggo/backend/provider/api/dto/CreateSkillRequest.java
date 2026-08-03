package com.giggo.backend.provider.api.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateSkillRequest(
        @NotNull UUID categoryId,
        @NotBlank @Size(max = 100) String name
) {}