package com.giggo.backend.notification.api.dto;

import com.giggo.backend.notification.domain.NotificationCategory;

import jakarta.validation.constraints.NotNull;

/** Toggle push for one notification category (P8.5). */
public record SetNotificationPreferenceRequest(
        @NotNull NotificationCategory category,
        boolean pushEnabled
) {}
