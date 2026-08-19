package com.giggo.backend.payment.api;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.payment.api.dto.PaymentResponse;
import com.giggo.backend.payment.api.dto.ReceiptResponse;
import com.giggo.backend.payment.service.PaymentService;
import com.giggo.backend.payment.service.PaymentService.PaymentResult;
import com.giggo.backend.payment.service.ReceiptService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Payments + escrow endpoints (P7.1). */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final ReceiptService receiptService;

    /** Start payment for a completed booking; returns a checkout session. */
    @PostMapping("/bookings/{bookingId}/payment")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<PaymentResponse> initiate(
            @AuthenticationPrincipal User user, @PathVariable UUID bookingId) {
        PaymentResult result = paymentService.initiate(user.getId(), bookingId);
        return ApiResponse.ok(PaymentResponse.of(result.payment(), result.checkoutUrl()));
    }

    /** Payment status for a booking (participants only). */
    @GetMapping("/bookings/{bookingId}/payment")
    public ApiResponse<PaymentResponse> get(
            @AuthenticationPrincipal User user, @PathVariable UUID bookingId) {
        return ApiResponse.ok(PaymentResponse.from(paymentService.getByBooking(user.getId(), bookingId)));
    }

    /** Receipt / invoice for a paid booking, once funds are captured (participants only). */
    @GetMapping("/bookings/{bookingId}/receipt")
    public ApiResponse<ReceiptResponse> receipt(
            @AuthenticationPrincipal User user, @PathVariable UUID bookingId) {
        return ApiResponse.ok(receiptService.forBooking(user.getId(), bookingId));
    }

    /** Gateway capture callback (stubbed): move funds into escrow. */
    @PostMapping("/payments/{id}/confirm")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<PaymentResponse> confirm(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(PaymentResponse.from(paymentService.confirm(user.getId(), id)));
    }

    /** Release escrow to the provider (minus commission) and settle the booking. */
    @PostMapping("/payments/{id}/release")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<PaymentResponse> release(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(PaymentResponse.from(paymentService.release(user.getId(), id)));
    }

    /** Refund escrowed funds to the customer before release (P4.5). */
    @PostMapping("/payments/{id}/refund")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<PaymentResponse> refund(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(PaymentResponse.from(paymentService.refund(user.getId(), id)));
    }
}
