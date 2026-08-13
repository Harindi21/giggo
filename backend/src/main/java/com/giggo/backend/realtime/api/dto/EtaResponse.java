package com.giggo.backend.realtime.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

/** ETA to a destination based on the provider's last-known position. */
public record EtaResponse(
        UUID jobId,
        double distanceKm,
        int etaMinutes,
        double speedKmhUsed,
        double providerLatitude,
        double providerLongitude,
        OffsetDateTime basedOn
) {}
