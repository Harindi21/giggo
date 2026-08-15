package com.giggo.backend.booking.repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /** All bookings a user is part of (as customer or provider), newest first. */
    List<Booking> findByCustomerIdOrProviderIdOrderByCreatedAtDesc(UUID customerId, UUID providerId);

    /** Bookings still in {@code status} whose request-expiry has passed (P4.4). */
    List<Booking> findByStatusAndRequestExpiresAtBefore(JobStatus status, OffsetDateTime cutoff);
}
