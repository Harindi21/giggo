package com.giggo.backend.review.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    /** Per-dimension rating averages for a provider's visible reviews (P6.6). */
    @Query("""
            SELECT AVG(r.serviceRating) AS service,
                   AVG(r.punctualityRating) AS punctuality,
                   AVG(r.valueRating) AS valueScore,
                   COUNT(r) AS total
            FROM Review r
            WHERE r.providerId = :providerId AND r.hidden = false
            """)
    RatingBreakdownProjection ratingBreakdown(@Param("providerId") UUID providerId);
}
