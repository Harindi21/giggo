package com.giggo.backend.notification.domain;

/** User-facing grouping of notification types, for push preferences (P8.5). */
public enum NotificationCategory {
    BOOKINGS,
    PAYMENTS,
    REVIEWS,
    SYSTEM;

    /** Map a notification {@code type} (e.g. BOOKING_ACCEPTED) to its category. */
    public static NotificationCategory of(String type) {
        if (type == null) {
            return SYSTEM;
        }
        if (type.startsWith("BOOKING")) {
            return BOOKINGS;
        }
        if (type.startsWith("PAYMENT")) {
            return PAYMENTS;
        }
        if (type.startsWith("REVIEW")) {
            return REVIEWS;
        }
        return SYSTEM;
    }
}
