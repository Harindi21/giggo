package com.giggo.backend.review.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.review.domain.Review;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    boolean existsByBookingId(UUID bookingId);
    List<Review> findByProviderIdOrderByCreatedAtDesc(UUID providerId);
}
