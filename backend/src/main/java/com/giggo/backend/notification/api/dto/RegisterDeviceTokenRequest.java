package com.giggo.backend.notification.api.dto;

import com.giggo.backend.notification.domain.DevicePlatform;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegisterDeviceTokenRequest(
        @NotBlank @Size(max = 300) String token,
        @NotNull DevicePlatform platform
) {}
