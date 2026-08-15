package com.giggo.backend.notification.service;

import java.util.Optional;
import java.util.UUID;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;

/**
 * Decides who to notify and what to say for each booking status change (P8.1).
 * Pure and side-effect free so it is easy to unit test.
 */
public final class BookingNotificationPlanner {

    private BookingNotificationPlanner() {}

    public record NotificationPlan(UUID recipientId, String type, String title, String body) {}

    public static Optional<NotificationPlan> plan(Booking booking, JobStatus status) {
        UUID customer = booking.getCustomerId();
        UUID provider = booking.getProviderId();
        return switch (status) {
            case REQUESTED -> of(provider, "BOOKING_REQUESTED", "New booking request",
                    "You have a new booking request. Tap to review.");
            case ACCEPTED -> of(customer, "BOOKING_ACCEPTED", "Booking accepted",
                    "Your provider accepted the booking.");
            case EN_ROUTE -> of(customer, "BOOKING_EN_ROUTE", "Provider on the way",
                    "Your provider is heading to your location.");
            case STARTED -> of(customer, "BOOKING_STARTED", "Job started",
                    "Work on your booking has started.");
            case COMPLETED -> of(customer, "BOOKING_COMPLETED", "Job completed",
                    "Your job is complete. Pay and leave a review.");
            case DECLINED -> of(customer, "BOOKING_DECLINED", "Request declined",
                    "Your provider declined the request.");
            case EXPIRED -> of(customer, "BOOKING_EXPIRED", "Request expired",
                    "Your booking request expired without a response.");
            case RATED -> of(provider, "REVIEW_RECEIVED", "New review",
                    "You received a new review.");
            case PAID -> of(provider, "PAYMENT_RELEASED", "Payment received",
                    "Escrow was released to you for a completed job.");
            case CANCELLED -> of(otherParty(booking), "BOOKING_CANCELLED", "Booking cancelled",
                    "A booking was cancelled.");
        };
    }

    /** The participant who did not cancel (falls back to the customer). */
    private static UUID otherParty(Booking booking) {
        UUID actor = booking.getCancelledBy();
        return booking.getCustomerId().equals(actor)
                ? booking.getProviderId()
                : booking.getCustomerId();
    }

    private static Optional<NotificationPlan> of(UUID recipient, String type, String title, String body) {
        return Optional.of(new NotificationPlan(recipient, type, title, body));
    }
}
