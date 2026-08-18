package com.giggo.backend.dispute.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.dispute.domain.Dispute;
import com.giggo.backend.dispute.domain.DisputeStatus;
import com.giggo.backend.dispute.repository.DisputeRepository;
import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.payment.service.PaymentService;

import lombok.RequiredArgsConstructor;

/**
 * Booking disputes (P4.6). A participant can raise a dispute once work has
 * started; an admin resolves it by refunding the escrow or dismissing it.
 */
@Service
@RequiredArgsConstructor
public class DisputeService {

    /** Disputes only make sense once the provider has actually started work. */
    private static final Set<JobStatus> DISPUTABLE = Set.of(
            JobStatus.STARTED, JobStatus.COMPLETED, JobStatus.RATED, JobStatus.PAID);

    private final DisputeRepository disputeRepository;
    private final BookingService bookingService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;

    @Transactional
    public Dispute raise(UUID userId, UUID bookingId, String reason) {
        BookingResponse booking = bookingService.getById(userId, bookingId); // validates participant
        if (!DISPUTABLE.contains(booking.status())) {
            throw new IllegalArgumentException(
                    "You can only dispute a job once work has started.");
        }
        if (disputeRepository.existsByBookingId(bookingId)) {
            throw new DuplicateResourceException("A dispute already exists for this booking");
        }
        Dispute dispute = disputeRepository.save(Dispute.builder()
                .bookingId(bookingId)
                .raisedBy(userId)
                .reason(reason)
                .status(DisputeStatus.OPEN)
                .build());

        UUID other = booking.customerId().equals(userId)
                ? booking.providerId() : booking.customerId();
        notificationService.notify(other, "DISPUTE_RAISED", "Dispute raised",
                "A dispute was raised on one of your bookings. Our team will review it.", bookingId);
        return dispute;
    }

    @Transactional(readOnly = true)
    public Dispute getByBooking(UUID userId, UUID bookingId) {
        bookingService.getById(userId, bookingId); // validates participant
        return disputeRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("No dispute for this booking"));
    }

    @Transactional(readOnly = true)
    public List<Dispute> listByStatus(DisputeStatus status) {
        return disputeRepository.findByStatusOrderByCreatedAtAsc(status);
    }

    @Transactional
    public Dispute resolve(UUID adminId, UUID disputeId, boolean refund, String note) {
        Dispute dispute = disputeRepository.findById(disputeId)
                .orElseThrow(() -> new ResourceNotFoundException("Dispute not found"));
        if (dispute.getStatus() != DisputeStatus.OPEN) {
            throw new IllegalArgumentException("This dispute has already been resolved");
        }
        if (refund) {
            paymentService.refundHeldForBooking(dispute.getBookingId());
            dispute.setStatus(DisputeStatus.RESOLVED_REFUNDED);
        } else {
            dispute.setStatus(DisputeStatus.RESOLVED_DISMISSED);
        }
        dispute.setResolvedBy(adminId);
        dispute.setResolutionNote(note);
        dispute.setResolvedAt(OffsetDateTime.now());
        Dispute saved = disputeRepository.save(dispute);

        notificationService.notify(
                dispute.getRaisedBy(),
                refund ? "DISPUTE_REFUNDED" : "DISPUTE_DISMISSED",
                "Dispute resolved",
                refund
                        ? "Your dispute was resolved and any held payment was refunded."
                        : "Your dispute was reviewed and dismissed.",
                dispute.getBookingId());
        return saved;
    }
}
