package com.giggo.backend.payment.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.payment.domain.Payment;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByBookingId(UUID bookingId);

    /** A provider's payments, newest first — drives the earnings read-model (P7.5). */
    List<Payment> findByProviderIdOrderByCreatedAtDesc(UUID providerId);
}
