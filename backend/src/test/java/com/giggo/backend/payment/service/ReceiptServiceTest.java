package com.giggo.backend.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.payment.api.dto.ReceiptResponse;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ReceiptService")
class ReceiptServiceTest {

    @Mock PaymentService paymentService;
    @Mock BookingService bookingService;
    @Mock UserRepository userRepository;

    private ReceiptService service;

    private final UUID bookingId = UUID.fromString("1a2b3c4d-0000-0000-0000-000000000000");
    private final UUID customerId = UUID.randomUUID();
    private final UUID providerId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new ReceiptService(paymentService, bookingService, userRepository);
    }

    private Payment payment(PaymentStatus status) {
        return Payment.builder()
                .id(UUID.randomUUID())
                .bookingId(bookingId)
                .customerId(customerId)
                .providerId(providerId)
                .amount(new BigDecimal("1750.00"))
                .currency("LKR")
                .commission(new BigDecimal("175.00"))
                .providerPayout(new BigDecimal("1575.00"))
                .status(status)
                .gateway("stub")
                .paidAt(OffsetDateTime.of(2026, 8, 15, 10, 0, 0, 0, ZoneOffset.UTC))
                .build();
    }

    private BookingResponse booking() {
        Booking b = Booking.builder()
                .id(bookingId).customerId(customerId).providerId(providerId)
                .skillId(UUID.randomUUID()).status(JobStatus.PAID)
                .scheduledAt(OffsetDateTime.of(2026, 8, 16, 9, 0, 0, 0, ZoneOffset.UTC))
                .estimatedHours(new BigDecimal("2"))
                .taskTitle("Fix leaking pipe")
                .basePrice(new BigDecimal("500.00")).hourlyRate(new BigDecimal("500.00"))
                .workingHours(new BigDecimal("2.00")).workingFee(new BigDecimal("1000.00"))
                .travelDistanceKm(new BigDecimal("5.00")).travelFee(new BigDecimal("250.00"))
                .totalPrice(new BigDecimal("1750.00"))
                .completedAt(OffsetDateTime.of(2026, 8, 16, 11, 0, 0, 0, ZoneOffset.UTC))
                .build();
        return BookingResponse.from(b, "Plumbing");
    }

    @Test
    @DisplayName("builds a receipt with a stable number, line items and the escrow split")
    void buildsReceipt() {
        when(paymentService.getByBooking(customerId, bookingId)).thenReturn(payment(PaymentStatus.HELD));
        when(bookingService.getById(customerId, bookingId)).thenReturn(booking());
        when(userRepository.findById(customerId)).thenReturn(Optional.of(
                User.builder().id(customerId).fullName("Ann").build()));
        when(userRepository.findById(providerId)).thenReturn(Optional.of(
                User.builder().id(providerId).fullName("Kamal").build()));

        ReceiptResponse r = service.forBooking(customerId, bookingId);

        assertThat(r.receiptNumber()).isEqualTo("GIG-202608-1A2B3C4D");
        assertThat(r.customerName()).isEqualTo("Ann");
        assertThat(r.providerName()).isEqualTo("Kamal");
        assertThat(r.serviceName()).isEqualTo("Plumbing");
        assertThat(r.total()).isEqualByComparingTo("1750.00");
        assertThat(r.platformCommission()).isEqualByComparingTo("175.00");
        assertThat(r.providerPayout()).isEqualByComparingTo("1575.00");
        assertThat(r.paymentStatus()).isEqualTo("HELD");
        assertThat(r.currency()).isEqualTo("LKR");
    }

    @Test
    @DisplayName("no receipt until funds are captured")
    void rejectsBeforeCapture() {
        when(paymentService.getByBooking(customerId, bookingId)).thenReturn(payment(PaymentStatus.PENDING));
        assertThatThrownBy(() -> service.forBooking(customerId, bookingId))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
