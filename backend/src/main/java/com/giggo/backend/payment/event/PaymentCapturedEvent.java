package com.giggo.backend.payment.event;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Published after a customer's payment is captured into escrow (PENDING → HELD).
 * Delivered post-commit so side effects (notifications) never affect the payment
 * transaction itself (P8, see ADR-0005).
 */
public record PaymentCapturedEvent(UUID bookingId, UUID providerId, UUID customerId, BigDecimal amount) {}
