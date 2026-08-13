package com.giggo.backend.realtime.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.realtime.domain.ConsentStatus;
import com.giggo.backend.realtime.domain.TrackingConsent;

public record TrackingConsentResponse(
        UUID id,
        UUID jobId,
        UUID customerId,
        UUID providerId,
        UUID requestedBy,
        ConsentStatus status,
        boolean active,
        OffsetDateTime grantedAt,
        OffsetDateTime expiresAt,
        OffsetDateTime createdAt
) {
    public static TrackingConsentResponse from(TrackingConsent c) {
        return new TrackingConsentResponse(
                c.getId(),
                c.getJobId(),
                c.getCustomerId(),
                c.getProviderId(),
                c.getRequestedBy(),
                c.getStatus(),
                c.isActive(),
                c.getGrantedAt(),
                c.getExpiresAt(),
                c.getCreatedAt()
        );
    }
}
