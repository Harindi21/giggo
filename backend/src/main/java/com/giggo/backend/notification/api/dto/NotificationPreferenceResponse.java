package com.giggo.backend.notification.api.dto;

import com.giggo.backend.notification.domain.NotificationCategory;

/** A user's push preference for one category (P8.5). */
public record NotificationPreferenceResponse(
        NotificationCategory category,
        boolean pushEnabled
) {}
