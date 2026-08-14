package com.giggo.backend.booking.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.booking.domain.Booking;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /** All bookings a user is part of (as customer or provider), newest first. */
    List<Booking> findByCustomerIdOrProviderIdOrderByCreatedAtDesc(UUID customerId, UUID providerId);
}
