package com.giggo.backend.realtime.service;

import static com.giggo.backend.realtime.domain.ConsentStatus.GRANTED;
import static com.giggo.backend.realtime.domain.ConsentStatus.PENDING;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.realtime.api.dto.RequestConsentRequest;
import com.giggo.backend.realtime.api.dto.TrackingConsentResponse;
import com.giggo.backend.realtime.domain.ConsentStatus;
import com.giggo.backend.realtime.domain.TrackingConsent;
import com.giggo.backend.realtime.repository.TrackingConsentRepository;

import lombok.RequiredArgsConstructor;

/**
 * Privacy gate for live tracking (P5.2). A participant requests consent for a job;
 * the other party grants it for a time-boxed window; either party may revoke early.
 * No location is ever broadcast (P5.3) unless {@link #isSharingAllowed} is true.
 */
@Service
@RequiredArgsConstructor
public class TrackingConsentService {

    private static final int DEFAULT_DURATION_MINUTES = 60;
    private static final int MAX_DURATION_MINUTES = 1440;

    private final TrackingConsentRepository repository;

    @Transactional
    public TrackingConsentResponse request(UUID actorId, RequestConsentRequest req) {
        if (req.customerId().equals(req.providerId())) {
            throw new IllegalArgumentException("Customer and provider must be different");
        }
        if (!actorId.equals(req.customerId()) && !actorId.equals(req.providerId())) {
            throw new ForbiddenOperationException("Only a participant can request tracking consent");
        }
        if (repository.existsByJobIdAndStatusIn(req.jobId(), List.of(PENDING, GRANTED))) {
            throw new DuplicateResourceException("An active tracking consent already exists for this job");
        }
        TrackingConsent consent = TrackingConsent.builder()
                .jobId(req.jobId())
                .customerId(req.customerId())
                .providerId(req.providerId())
                .requestedBy(actorId)
                .status(PENDING)
                .build();
        return TrackingConsentResponse.from(repository.save(consent));
    }

    @Transactional
    public TrackingConsentResponse grant(UUID actorId, UUID id, Integer durationMinutes) {
        TrackingConsent consent = participantConsent(id, actorId);
        if (actorId.equals(consent.getRequestedBy())) {
            throw new IllegalArgumentException("The other party must accept — you cannot grant your own request");
        }
        requirePending(consent);
        int minutes = durationMinutes == null
                ? DEFAULT_DURATION_MINUTES
                : Math.max(1, Math.min(MAX_DURATION_MINUTES, durationMinutes));
        OffsetDateTime now = OffsetDateTime.now();
        consent.setStatus(GRANTED);
        consent.setGrantedAt(now);
        consent.setExpiresAt(now.plusMinutes(minutes));
        return TrackingConsentResponse.from(repository.save(consent));
    }

    @Transactional
    public TrackingConsentResponse decline(UUID actorId, UUID id) {
        TrackingConsent consent = participantConsent(id, actorId);
        if (actorId.equals(consent.getRequestedBy())) {
            throw new IllegalArgumentException("The requester cannot decline their own request");
        }
        requirePending(consent);
        consent.setStatus(ConsentStatus.DECLINED);
        return TrackingConsentResponse.from(repository.save(consent));
    }

    @Transactional
    public TrackingConsentResponse revoke(UUID actorId, UUID id) {
        TrackingConsent consent = participantConsent(id, actorId);
        if (consent.getStatus() != PENDING && consent.getStatus() != GRANTED) {
            throw new IllegalArgumentException("Only a pending or active consent can be revoked");
        }
        consent.setStatus(ConsentStatus.REVOKED);
        return TrackingConsentResponse.from(repository.save(consent));
    }

    @Transactional(readOnly = true)
    public TrackingConsentResponse forJob(UUID jobId) {
        return TrackingConsentResponse.from(
                repository.findFirstByJobIdOrderByCreatedAtDesc(jobId)
                        .orElseThrow(() -> new ResourceNotFoundException("No tracking consent for this job")));
    }

    /** Used by the location broadcaster (P5.3) to decide whether sharing is permitted. */
    @Transactional(readOnly = true)
    public boolean isSharingAllowed(UUID jobId) {
        return repository.findByJobIdAndStatus(jobId, GRANTED)
                .map(TrackingConsent::isActive)
                .orElse(false);
    }

    private TrackingConsent participantConsent(UUID id, UUID actorId) {
        TrackingConsent consent = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Consent not found"));
        if (!consent.isParticipant(actorId)) {
            throw new ForbiddenOperationException("You are not a participant of this consent");
        }
        return consent;
    }

    private void requirePending(TrackingConsent consent) {
        if (consent.getStatus() != PENDING) {
            throw new IllegalArgumentException("Consent is not pending");
        }
    }
}
