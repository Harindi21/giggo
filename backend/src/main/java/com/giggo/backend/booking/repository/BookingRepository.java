package com.giggo.backend.booking.repository;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /** All bookings a user is part of (as customer or provider), newest first. */
    List<Booking> findByCustomerIdOrProviderIdOrderByCreatedAtDesc(UUID customerId, UUID providerId);

    /** Bookings still in {@code status} whose request-expiry has passed (P4.4). */
    List<Booking> findByStatusAndRequestExpiresAtBefore(JobStatus status, OffsetDateTime cutoff);

    /** How many bookings a customer currently has open, for the anti-fraud throttle (P6.4). */
    long countByCustomerIdAndStatusIn(UUID customerId, Collection<JobStatus> statuses);

    /** A provider's bookings in the given states, for double-booking checks (P3.3). */
    List<Booking> findByProviderIdAndStatusIn(UUID providerId, Collection<JobStatus> statuses);

    // ---- Admin analytics (P11.1/P11.7) ----

    long countByStatusIn(Collection<JobStatus> statuses);

    /** Most-booked service categories, busiest first. */
    @Query(value = """
            SELECT c.name AS name, COUNT(*) AS total
            FROM bookings b
            JOIN skills s ON b.skill_id = s.id
            JOIN categories c ON s.category_id = c.id
            GROUP BY c.name
            ORDER BY COUNT(*) DESC
            LIMIT 5
            """, nativeQuery = true)
    List<CategoryBookingCount> topCategories();

    @Query(value = "SELECT COUNT(DISTINCT customer_id) FROM bookings", nativeQuery = true)
    long countDistinctCustomers();

    @Query(value = "SELECT COUNT(*) FROM "
            + "(SELECT customer_id FROM bookings GROUP BY customer_id HAVING COUNT(*) > 1) t",
            nativeQuery = true)
    long countRepeatCustomers();
}
