package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;

public record PaymentResponse(
        UUID id,
        UUID bookingId,
        BigDecimal amount,
        String currency,
        BigDecimal commission,
        BigDecimal providerPayout,
        PaymentStatus status,
        String gateway,
        String gatewayRef,
        String checkoutUrl,   // only present right after initiate
        OffsetDateTime paidAt,
        OffsetDateTime releasedAt,
        OffsetDateTime createdAt
) {
    public static PaymentResponse from(Payment p) {
        return of(p, null);
    }

    public static PaymentResponse of(Payment p, String checkoutUrl) {
        return new PaymentResponse(
                p.getId(), p.getBookingId(), p.getAmount(), p.getCurrency(),
                p.getCommission(), p.getProviderPayout(), p.getStatus(),
                p.getGateway(), p.getGatewayRef(), checkoutUrl,
                p.getPaidAt(), p.getReleasedAt(), p.getCreatedAt());
    }
}
