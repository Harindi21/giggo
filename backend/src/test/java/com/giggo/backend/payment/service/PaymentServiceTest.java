package com.giggo.backend.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.event.PaymentCapturedEvent;
import com.giggo.backend.payment.gateway.StubPaymentGateway;
import com.giggo.backend.payment.repository.PaymentRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("PaymentService")
class PaymentServiceTest {

    @Mock PaymentRepository paymentRepository;
    @Mock BookingService bookingService;
    @Mock ApplicationEventPublisher events;

    private PaymentService service;

    private final UUID customerId = UUID.randomUUID();
    private final UUID providerUserId = UUID.randomUUID();
    private final UUID bookingId = UUID.randomUUID();
    private final UUID paymentId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new PaymentService(
                paymentRepository,
                bookingService,
                events,
                List.of(new StubPaymentGateway("https://sandbox.local/checkout")),
                "stub",
                new BigDecimal("0.10"));
        lenient().when(paymentRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private BookingResponse booking(JobStatus status, String total) {
        Booking b = Booking.builder()
                .id(bookingId)
                .customerId(customerId)
                .providerId(providerUserId)
                .skillId(UUID.randomUUID())
                .status(status)
                .totalPrice(new BigDecimal(total))
                .build();
        return BookingResponse.from(b, "Plumbing");
    }

    private Payment payment(PaymentStatus status) {
        return Payment.builder()
                .id(paymentId)
                .bookingId(bookingId)
                .customerId(customerId)
                .providerId(providerUserId)
                .amount(new BigDecimal("1000.00"))
                .commission(new BigDecimal("100.00"))
                .providerPayout(new BigDecimal("900.00"))
                .status(status)
                .gateway("stub")
                .build();
    }

    @Test
    @DisplayName("initiate splits commission and returns a checkout session")
    void initiateSplitsCommission() {
        when(bookingService.getById(customerId, bookingId))
                .thenReturn(booking(JobStatus.COMPLETED, "1000.00"));
        when(paymentRepository.findByBookingId(bookingId)).thenReturn(Optional.empty());

        PaymentService.PaymentResult result = service.initiate(customerId, bookingId);

        assertThat(result.checkoutUrl()).isNotNull();
        assertThat(result.payment().getStatus()).isEqualTo(PaymentStatus.PENDING);
        assertThat(result.payment().getCommission()).isEqualByComparingTo("100.00");
        assertThat(result.payment().getProviderPayout()).isEqualByComparingTo("900.00");
        assertThat(result.payment().getGatewayRef()).isNotBlank();
    }

    @Test
    @DisplayName("initiate is rejected before the job is completed")
    void initiateRejectsIncomplete() {
        when(bookingService.getById(customerId, bookingId))
                .thenReturn(booking(JobStatus.ACCEPTED, "1000.00"));

        assertThatThrownBy(() -> service.initiate(customerId, bookingId))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("confirm moves funds into escrow (HELD)")
    void confirmHoldsFunds() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.PENDING)));

        Payment out = service.confirm(customerId, paymentId);

        assertThat(out.getStatus()).isEqualTo(PaymentStatus.HELD);
        assertThat(out.getPaidAt()).isNotNull();
    }

    @Test
    @DisplayName("confirm publishes a PaymentCapturedEvent naming the provider (P8)")
    void confirmPublishesCapturedEvent() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.PENDING)));

        service.confirm(customerId, paymentId);

        ArgumentCaptor<PaymentCapturedEvent> captor = ArgumentCaptor.forClass(PaymentCapturedEvent.class);
        verify(events).publishEvent(captor.capture());
        assertThat(captor.getValue().providerId()).isEqualTo(providerUserId);
        assertThat(captor.getValue().bookingId()).isEqualTo(bookingId);
        assertThat(captor.getValue().amount()).isEqualByComparingTo("1000.00");
    }

    @Test
    @DisplayName("release pays out and settles the booking as PAID")
    void releasePaysOut() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.HELD)));

        Payment out = service.release(customerId, paymentId);

        assertThat(out.getStatus()).isEqualTo(PaymentStatus.RELEASED);
        assertThat(out.getReleasedAt()).isNotNull();
        verify(bookingService).markPaid(bookingId);
    }

    @Test
    @DisplayName("release requires funds to be held first")
    void releaseRequiresHeld() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.PENDING)));

        assertThatThrownBy(() -> service.release(customerId, paymentId))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("refund returns escrowed funds before release")
    void refundReturnsHeldFunds() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.HELD)));

        Payment out = service.refund(customerId, paymentId);

        assertThat(out.getStatus()).isEqualTo(PaymentStatus.REFUNDED);
        assertThat(out.getRefundedAt()).isNotNull();
    }

    @Test
    @DisplayName("refund requires funds to be held (not already released)")
    void refundRequiresHeld() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.RELEASED)));

        assertThatThrownBy(() -> service.refund(customerId, paymentId))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("only the paying customer can act on a payment")
    void rejectsNonOwner() {
        when(paymentRepository.findById(paymentId)).thenReturn(Optional.of(payment(PaymentStatus.PENDING)));

        assertThatThrownBy(() -> service.confirm(UUID.randomUUID(), paymentId))
                .isInstanceOf(ForbiddenOperationException.class);
    }
}
