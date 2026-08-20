package com.giggo.backend.payment.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;

public interface PayoutRepository extends JpaRepository<Payout, UUID> {

    List<Payout> findByProviderIdOrderByCreatedAtDesc(UUID providerId);

    /** Admin queue: payouts in a given state, oldest first (FIFO). */
    List<Payout> findByStatusOrderByRequestedAtAsc(PayoutStatus status);
}
