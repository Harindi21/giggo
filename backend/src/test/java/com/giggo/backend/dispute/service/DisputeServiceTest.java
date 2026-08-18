package com.giggo.backend.dispute.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
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
import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.dispute.domain.Dispute;
import com.giggo.backend.dispute.domain.DisputeStatus;
import com.giggo.backend.dispute.repository.DisputeRepository;
import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.payment.service.PaymentService;

@ExtendWith(MockitoExtension.class)
@DisplayName("DisputeService")
class DisputeServiceTest {

    @Mock DisputeRepository disputeRepository;
    @Mock BookingService bookingService;
    @Mock PaymentService paymentService;
    @Mock NotificationService notificationService;

    private DisputeService service;

    private final UUID customerId = UUID.randomUUID();
    private final UUID providerUserId = UUID.randomUUID();
    private final UUID bookingId = UUID.randomUUID();
    private final UUID disputeId = UUID.randomUUID();
    private final UUID adminId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new DisputeService(
                disputeRepository, bookingService, paymentService, notificationService);
        lenient().when(disputeRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        lenient().when(paymentService.refundHeldForBooking(any())).thenReturn(Optional.empty());
    }

    private BookingResponse booking(JobStatus status) {
        Booking b = Booking.builder()
                .id(bookingId).customerId(customerId).providerId(providerUserId)
                .skillId(UUID.randomUUID()).status(status)
                .totalPrice(new BigDecimal("1000"))
                .build();
        return BookingResponse.from(b, "Plumbing");
    }

    private Dispute openDispute() {
        return Dispute.builder()
                .id(disputeId).bookingId(bookingId).raisedBy(customerId)
                .reason("Work not finished").status(DisputeStatus.OPEN)
                .build();
    }

    @Test
    @DisplayName("raise creates an OPEN dispute and notifies the other party")
    void raiseCreatesAndNotifies() {
        when(bookingService.getById(customerId, bookingId))
                .thenReturn(booking(JobStatus.COMPLETED));
        when(disputeRepository.existsByBookingId(bookingId)).thenReturn(false);

        Dispute d = service.raise(customerId, bookingId, "Work not finished");

        assertThat(d.getStatus()).isEqualTo(DisputeStatus.OPEN);
        assertThat(d.getRaisedBy()).isEqualTo(customerId);
        verify(notificationService).notify(
                eq(providerUserId), eq("DISPUTE_RAISED"), anyString(), anyString(), eq(bookingId));
    }

    @Test
    @DisplayName("cannot dispute before work has started")
    void rejectsNonDisputableStatus() {
        when(bookingService.getById(customerId, bookingId))
                .thenReturn(booking(JobStatus.REQUESTED));

        assertThatThrownBy(() -> service.raise(customerId, bookingId, "x"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("only one dispute per booking")
    void rejectsDuplicate() {
        when(bookingService.getById(customerId, bookingId))
                .thenReturn(booking(JobStatus.COMPLETED));
        when(disputeRepository.existsByBookingId(bookingId)).thenReturn(true);

        assertThatThrownBy(() -> service.raise(customerId, bookingId, "x"))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    @DisplayName("resolve with refund refunds escrow and marks RESOLVED_REFUNDED")
    void resolveRefunds() {
        when(disputeRepository.findById(disputeId)).thenReturn(Optional.of(openDispute()));

        Dispute d = service.resolve(adminId, disputeId, true, "Valid complaint");

        assertThat(d.getStatus()).isEqualTo(DisputeStatus.RESOLVED_REFUNDED);
        assertThat(d.getResolvedBy()).isEqualTo(adminId);
        verify(paymentService).refundHeldForBooking(bookingId);
        verify(notificationService).notify(
                eq(customerId), eq("DISPUTE_REFUNDED"), anyString(), anyString(), eq(bookingId));
    }

    @Test
    @DisplayName("resolve with dismiss does not refund")
    void resolveDismisses() {
        when(disputeRepository.findById(disputeId)).thenReturn(Optional.of(openDispute()));

        Dispute d = service.resolve(adminId, disputeId, false, "Not upheld");

        assertThat(d.getStatus()).isEqualTo(DisputeStatus.RESOLVED_DISMISSED);
        verify(paymentService, never()).refundHeldForBooking(any());
        verify(notificationService).notify(
                eq(customerId), eq("DISPUTE_DISMISSED"), anyString(), anyString(), eq(bookingId));
    }

    @Test
    @DisplayName("cannot resolve an already-resolved dispute")
    void rejectsAlreadyResolved() {
        Dispute resolved = openDispute();
        resolved.setStatus(DisputeStatus.RESOLVED_DISMISSED);
        when(disputeRepository.findById(disputeId)).thenReturn(Optional.of(resolved));

        assertThatThrownBy(() -> service.resolve(adminId, disputeId, true, null))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
