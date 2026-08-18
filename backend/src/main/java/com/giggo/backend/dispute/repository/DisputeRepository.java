package com.giggo.backend.dispute.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.dispute.domain.Dispute;
import com.giggo.backend.dispute.domain.DisputeStatus;

public interface DisputeRepository extends JpaRepository<Dispute, UUID> {
    Optional<Dispute> findByBookingId(UUID bookingId);
    boolean existsByBookingId(UUID bookingId);
    List<Dispute> findByStatusOrderByCreatedAtAsc(DisputeStatus status);
}
