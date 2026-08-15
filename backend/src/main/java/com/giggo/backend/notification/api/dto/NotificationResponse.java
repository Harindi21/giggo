package com.giggo.backend.notification.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.notification.domain.Notification;

public record NotificationResponse(
        UUID id,
        String type,
        String title,
        String body,
        UUID bookingId,
        boolean read,
        OffsetDateTime createdAt
) {
    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(
                n.getId(), n.getType(), n.getTitle(), n.getBody(),
                n.getBookingId(), n.getReadAt() != null, n.getCreatedAt());
    }
}
