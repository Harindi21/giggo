package com.giggo.backend.dispute.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.dispute.domain.Dispute;
import com.giggo.backend.dispute.domain.DisputeStatus;

public record DisputeResponse(
        UUID id,
        UUID bookingId,
        UUID raisedBy,
        String reason,
        DisputeStatus status,
        String resolutionNote,
        OffsetDateTime createdAt,
        OffsetDateTime resolvedAt
) {
    public static DisputeResponse from(Dispute d) {
        return new DisputeResponse(
                d.getId(), d.getBookingId(), d.getRaisedBy(), d.getReason(),
                d.getStatus(), d.getResolutionNote(), d.getCreatedAt(), d.getResolvedAt());
    }
}
