package com.giggo.backend.payment.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.gateway.CheckoutSession;
import com.giggo.backend.payment.gateway.PaymentGateway;
import com.giggo.backend.payment.repository.PaymentRepository;

/**
 * Payments with platform escrow (P7.1): the customer pays for a completed job,
 * funds are held by the platform, then released to the provider minus the
 * platform commission. The gateway is pluggable (stub by default; PayHere seam).
 */
@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final BookingService bookingService;
    private final PaymentGateway gateway;
    private final BigDecimal commissionRate;

    public PaymentService(
            PaymentRepository paymentRepository,
            BookingService bookingService,
            List<PaymentGateway> gateways,
            @Value("${giggo.payments.gateway:stub}") String gatewayName,
            @Value("${giggo.payments.commission-rate:0.10}") BigDecimal commissionRate) {
        this.paymentRepository = paymentRepository;
        this.bookingService = bookingService;
        this.gateway = gateways.stream()
                .filter(g -> g.name().equalsIgnoreCase(gatewayName))
                .findFirst()
                .orElse(gateways.get(0));
        this.commissionRate = commissionRate;
    }

    /** Start (or resume) payment for a completed booking; returns a checkout session. */
    @Transactional
    public PaymentResult initiate(UUID customerId, UUID bookingId) {
        BookingResponse booking = bookingService.getById(customerId, bookingId);
        if (!booking.customerId().equals(customerId)) {
            throw new ForbiddenOperationException("Only the customer can pay for this booking");
        }
        if (booking.status() != JobStatus.COMPLETED && booking.status() != JobStatus.RATED) {
            throw new IllegalArgumentException("Payment is available once the job is completed");
        }

        Optional<Payment> existing = paymentRepository.findByBookingId(bookingId);
        Payment payment = existing.orElseGet(() -> newPayment(booking));

        // Already captured or settled: nothing more to pay.
        if (payment.getStatus() == PaymentStatus.HELD
                || payment.getStatus() == PaymentStatus.RELEASED
                || payment.getStatus() == PaymentStatus.REFUNDED) {
            return new PaymentResult(payment, null);
        }

        // New, PENDING or previously FAILED: (re)create a checkout session.
        CheckoutSession session = gateway.initiate(payment);
        payment.setGateway(session.gateway());
        payment.setGatewayRef(session.gatewayRef());
        payment.setStatus(PaymentStatus.PENDING);
        return new PaymentResult(paymentRepository.save(payment), session.checkoutUrl());
    }

    /** Gateway capture callback (stubbed): move funds into escrow. */
    @Transactional
    public Payment confirm(UUID actingUserId, UUID paymentId) {
        Payment payment = get(paymentId);
        requireCustomer(payment, actingUserId);
        if (payment.getStatus() == PaymentStatus.HELD
                || payment.getStatus() == PaymentStatus.RELEASED) {
            return payment; // idempotent
        }
        if (payment.getStatus() != PaymentStatus.PENDING) {
            throw new IllegalArgumentException(
                    "Cannot confirm a payment in state " + payment.getStatus());
        }
        payment.setStatus(PaymentStatus.HELD);
        payment.setPaidAt(OffsetDateTime.now());
        return paymentRepository.save(payment);
    }

    /** Release escrow to the provider (minus commission) and settle the booking. */
    @Transactional
    public Payment release(UUID actingUserId, UUID paymentId) {
        Payment payment = get(paymentId);
        requireCustomer(payment, actingUserId);
        if (payment.getStatus() == PaymentStatus.RELEASED) {
            return payment; // idempotent
        }
        if (payment.getStatus() != PaymentStatus.HELD) {
            throw new IllegalArgumentException("Only funds held in escrow can be released");
        }
        payment.setStatus(PaymentStatus.RELEASED);
        payment.setReleasedAt(OffsetDateTime.now());
        Payment saved = paymentRepository.save(payment);
        bookingService.markPaid(payment.getBookingId());
        return saved;
    }

    @Transactional(readOnly = true)
    public Payment getByBooking(UUID actingUserId, UUID bookingId) {
        bookingService.getById(actingUserId, bookingId); // validates participation
        return paymentRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("No payment for this booking"));
    }

    private Payment newPayment(BookingResponse booking) {
        BigDecimal amount = booking.totalPrice();
        BigDecimal commission = amount.multiply(commissionRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal payout = amount.subtract(commission);
        return Payment.builder()
                .bookingId(booking.id())
                .customerId(booking.customerId())
                .providerId(booking.providerId())
                .amount(amount)
                .currency("LKR")
                .commission(commission)
                .providerPayout(payout)
                .status(PaymentStatus.PENDING)
                .gateway(gateway.name())
                .build();
    }

    private Payment get(UUID id) {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found"));
    }

    private void requireCustomer(Payment payment, UUID userId) {
        if (!payment.getCustomerId().equals(userId)) {
            throw new ForbiddenOperationException("You cannot act on this payment");
        }
    }

    /** A payment plus the one-time checkout URL returned when it is initiated. */
    public record PaymentResult(Payment payment, String checkoutUrl) {}
}
