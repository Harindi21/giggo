package com.giggo.backend.booking.event;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.booking.domain.JobStatus;

/** Published after a booking's status changes; broadcast to subscribers post-commit. */
public record BookingStatusChangedEvent(UUID bookingId, JobStatus status, OffsetDateTime at) {}
