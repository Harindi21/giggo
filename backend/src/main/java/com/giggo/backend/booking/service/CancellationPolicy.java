package com.giggo.backend.booking.service;

import java.util.EnumSet;
import java.util.Set;

import com.giggo.backend.booking.domain.JobStatus;

/**
 * Booking cancellation rules (P4.5). Either party may cancel up to (and
 * including) the provider being en route; once work has started it can no longer
 * be cancelled. Pure and side-effect free for easy testing.
 */
public final class CancellationPolicy {

    private CancellationPolicy() {}

    private static final Set<JobStatus> CANCELLABLE =
            EnumSet.of(JobStatus.REQUESTED, JobStatus.ACCEPTED, JobStatus.EN_ROUTE);

    public static boolean canCancel(JobStatus status) {
        return CANCELLABLE.contains(status);
    }

    /** Human-readable reason a booking in this status cannot be cancelled. */
    public static String blockedReason(JobStatus status) {
        return switch (status) {
            case STARTED -> "Work has already started; this booking can no longer be cancelled.";
            case COMPLETED, RATED, PAID -> "This booking is already completed.";
            case CANCELLED -> "This booking is already cancelled.";
            case DECLINED -> "This booking was declined.";
            case EXPIRED -> "This booking request has expired.";
            default -> "This booking cannot be cancelled.";
        };
    }
}
