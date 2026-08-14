package com.giggo.backend.booking.domain;

/** Booking / job lifecycle. Transitions are enforced by the state machine (P4.3). */
public enum JobStatus {
    REQUESTED,   // created, awaiting provider acceptance
    ACCEPTED,    // provider accepted
    EN_ROUTE,    // provider on the way
    STARTED,     // work in progress
    COMPLETED,   // work done, awaiting rating/payment
    RATED,       // customer left a review
    PAID,        // settled
    CANCELLED,   // cancelled by customer or provider
    EXPIRED,     // provider did not respond before request_expires_at
    DECLINED     // provider rejected the request
}
