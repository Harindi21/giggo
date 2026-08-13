package com.giggo.backend.realtime.repository;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.realtime.domain.ConsentStatus;
import com.giggo.backend.realtime.domain.TrackingConsent;

public interface TrackingConsentRepository extends JpaRepository<TrackingConsent, UUID> {

    Optional<TrackingConsent> findFirstByJobIdOrderByCreatedAtDesc(UUID jobId);

    Optional<TrackingConsent> findByJobIdAndStatus(UUID jobId, ConsentStatus status);

    boolean existsByJobIdAndStatusIn(UUID jobId, Collection<ConsentStatus> statuses);
}
