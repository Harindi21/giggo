package com.giggo.backend.payment.service;

import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.payment.api.dto.ReceiptResponse;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Builds a receipt / invoice for a paid booking (P4.12-4.14). A receipt exists only
 * once funds have been captured (escrow HELD) or settled (RELEASED); it combines the
 * booking's snapshotted price line items with the payment's escrow split.
 */
@Service
@RequiredArgsConstructor
public class ReceiptService {

    private final PaymentService paymentService;
    private final BookingService bookingService;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public ReceiptResponse forBooking(UUID actingUserId, UUID bookingId) {
        // getByBooking validates participation and 404s when there is no payment.
        Payment payment = paymentService.getByBooking(actingUserId, bookingId);
        if (payment.getStatus() != PaymentStatus.HELD && payment.getStatus() != PaymentStatus.RELEASED) {
            throw new IllegalArgumentException(
                    "A receipt is available once your payment has been captured");
        }
        BookingResponse booking = bookingService.getById(actingUserId, bookingId);
        return ReceiptResponse.of(payment, booking,
                nameOf(payment.getCustomerId()), nameOf(payment.getProviderId()));
    }

    private String nameOf(UUID userId) {
        return userRepository.findById(userId).map(User::getFullName).orElse(null);
    }
}
