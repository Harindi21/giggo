package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;

public record PayoutResponse(
        UUID id,
        UUID providerId,
        String providerName,
        BigDecimal amount,
        String currency,
        PayoutStatus status,
        String method,
        String reference,
        String note,
        OffsetDateTime requestedAt,
        OffsetDateTime processedAt
) {
    public static PayoutResponse from(Payout p) {
        return from(p, null);
    }

    public static PayoutResponse from(Payout p, String providerName) {
        return new PayoutResponse(
                p.getId(), p.getProviderId(), providerName, p.getAmount(), p.getCurrency(),
                p.getStatus(), p.getMethod(), p.getReference(), p.getNote(),
                p.getRequestedAt(), p.getProcessedAt());
    }
}
