package com.giggo.backend.realtime.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

/** Outbound provider position, broadcast to the customer and cached as last-known. */
public record ProviderLocation(
        UUID jobId,
        double latitude,
        double longitude,
        Double headingDegrees,
        Double speedKmh,
        Double accuracyMeters,
        OffsetDateTime at
) {}
