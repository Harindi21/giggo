package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.payment.domain.Payment;

/**
 * A payment receipt / invoice for a completed, paid booking (P4.12-4.14): the
 * snapshotted price line items plus the escrow settlement, with a stable,
 * human-readable receipt number.
 */
public record ReceiptResponse(
        String receiptNumber,
        OffsetDateTime issuedAt,
        UUID bookingId,
        UUID paymentId,
        String customerName,
        String providerName,
        String serviceName,
        String taskTitle,
        OffsetDateTime scheduledAt,
        OffsetDateTime completedAt,
        // ---- price line items (snapshotted at booking) ----
        BigDecimal basePrice,
        BigDecimal hourlyRate,
        BigDecimal workingHours,
        BigDecimal workingFee,
        BigDecimal travelDistanceKm,
        BigDecimal travelFee,
        BigDecimal total,
        String currency,
        // ---- payment / escrow ----
        String paymentStatus,
        String gateway,
        OffsetDateTime paidAt,
        BigDecimal platformCommission,
        BigDecimal providerPayout
) {
    private static final DateTimeFormatter PERIOD = DateTimeFormatter.ofPattern("yyyyMM");

    public static ReceiptResponse of(
            Payment payment, BookingResponse booking, String customerName, String providerName) {
        return new ReceiptResponse(
                receiptNumber(payment),
                payment.getPaidAt(),
                booking.id(),
                payment.getId(),
                customerName,
                providerName,
                booking.skillName(),
                booking.taskTitle(),
                booking.scheduledAt(),
                booking.completedAt(),
                booking.basePrice(),
                booking.hourlyRate(),
                booking.workingHours(),
                booking.workingFee(),
                booking.travelDistanceKm(),
                booking.travelFee(),
                booking.totalPrice(),
                payment.getCurrency(),
                payment.getStatus().name(),
                payment.getGateway(),
                payment.getPaidAt(),
                payment.getCommission(),
                payment.getProviderPayout());
    }

    /** Stable, per-booking receipt number, e.g. {@code GIG-202608-1A2B3C4D}. */
    private static String receiptNumber(Payment payment) {
        String period = (payment.getPaidAt() != null ? payment.getPaidAt() : payment.getCreatedAt())
                .format(PERIOD);
        String shortId = payment.getBookingId().toString().substring(0, 8).toUpperCase();
        return "GIG-" + period + "-" + shortId;
    }
}
