package com.giggo.backend.review.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.review.domain.Review;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    boolean existsByBookingId(UUID bookingId);

    /** Same customer, same review text on another job — a copy-paste spam signal (P6.4). */
    boolean existsByCustomerIdAndBody(UUID customerId, String body);

    /** Public listing: visible reviews only (P6.5). */
    List<Review> findByProviderIdAndHiddenFalseOrderByCreatedAtDesc(UUID providerId);

    /** Admin moderation queue: reported reviews, most-reported first. */
    List<Review> findTop100ByReportCountGreaterThanOrderByReportCountDesc(int threshold);

    /** Admin: recent reviews across the platform. */
    List<Review> findTop100ByOrderByCreatedAtDesc();
}
