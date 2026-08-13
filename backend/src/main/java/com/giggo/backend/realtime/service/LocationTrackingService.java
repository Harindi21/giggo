package com.giggo.backend.realtime.service;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.realtime.api.dto.LocationUpdate;
import com.giggo.backend.realtime.api.dto.ProviderLocation;

import lombok.RequiredArgsConstructor;

/**
 * Relays a provider's live location to the customer during a consented job (P5.3).
 *
 * <p>Every ping is gated by {@link TrackingConsentService#canShareLocation}: no
 * broadcast happens without an active GRANTED consent whose provider is the sender.
 * The last-known position is cached in memory so a customer joining mid-journey (or
 * reconnecting) can render immediately via the REST endpoint. Single-instance for
 * Phase 1; a Redis-backed store is the horizontal-scale swap.
 */
@Service
@RequiredArgsConstructor
public class LocationTrackingService {

    private final TrackingConsentService consentService;
    private final SimpMessagingTemplate messaging;

    private final Map<UUID, ProviderLocation> lastKnown = new ConcurrentHashMap<>();

    public ProviderLocation publish(UUID jobId, UUID providerUserId, LocationUpdate update) {
        validate(update);
        if (!consentService.canShareLocation(jobId, providerUserId)) {
            throw new ForbiddenOperationException("Live location sharing is not permitted for this job");
        }
        ProviderLocation location = new ProviderLocation(
                jobId,
                update.latitude(),
                update.longitude(),
                update.headingDegrees(),
                update.speedKmh(),
                update.accuracyMeters(),
                OffsetDateTime.now());

        lastKnown.put(jobId, location);
        messaging.convertAndSend(topic(jobId), location);
        return location;
    }

    public Optional<ProviderLocation> lastKnown(UUID jobId) {
        return Optional.ofNullable(lastKnown.get(jobId));
    }

    /** Drop the cached position (e.g. when a job ends). */
    public void clear(UUID jobId) {
        lastKnown.remove(jobId);
    }

    static String topic(UUID jobId) {
        return "/topic/jobs/" + jobId + "/location";
    }

    private void validate(LocationUpdate u) {
        if (u.latitude() == null || u.longitude() == null) {
            throw new IllegalArgumentException("latitude and longitude are required");
        }
        if (u.latitude() < -90 || u.latitude() > 90 || u.longitude() < -180 || u.longitude() > 180) {
            throw new IllegalArgumentException("Coordinates out of range");
        }
    }
}
