package com.giggo.backend.booking.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.booking.domain.BookingStatusEvent;

public interface BookingStatusEventRepository extends JpaRepository<BookingStatusEvent, UUID> {
    List<BookingStatusEvent> findByBookingIdOrderByAtAsc(UUID bookingId);
}
