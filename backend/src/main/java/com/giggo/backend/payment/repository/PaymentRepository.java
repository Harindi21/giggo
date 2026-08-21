package com.giggo.backend.payment.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByBookingId(UUID bookingId);

    /** A provider's payments, newest first — drives the earnings read-model (P7.5). */
    List<Payment> findByProviderIdOrderByCreatedAtDesc(UUID providerId);

    // ---- Admin analytics (P11.1) ----

    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = :status")
    BigDecimal sumAmountByStatus(@Param("status") PaymentStatus status);

    @Query("SELECT COALESCE(SUM(p.commission), 0) FROM Payment p WHERE p.status = :status")
    BigDecimal sumCommissionByStatus(@Param("status") PaymentStatus status);
}
