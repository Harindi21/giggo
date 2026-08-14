package com.giggo.backend.booking.service;

import java.time.OffsetDateTime;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.api.dto.CreateBookingRequest;
import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.api.dto.StatusEventResponse;
import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.BookingStatusEvent;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.event.BookingStatusChangedEvent;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.repository.BookingStatusEventRepository;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;

import lombok.RequiredArgsConstructor;

/** Creates and reads bookings; snapshots the price from the pricing engine (P4.1). */
@Service
@RequiredArgsConstructor
public class BookingService {

    private static final int DEFAULT_EXPIRY_MINUTES = 30;

    private final BookingRepository bookingRepository;
    private final BookingStatusEventRepository eventRepository;
    private final ProviderProfileRepository providerRepository;
    private final SkillRepository skillRepository;
    private final PricingService pricingService;
    private final ApplicationEventPublisher events;

    @Transactional
    public BookingResponse create(UUID customerId, CreateBookingRequest req) {
        ProviderProfile provider = providerRepository.findById(req.providerId())
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found"));
        UUID providerUserId = provider.getUser().getId();
        if (providerUserId.equals(customerId)) {
            throw new IllegalArgumentException("You cannot book yourself");
        }
        Skill skill = skillRepository.findById(req.skillId())
                .orElseThrow(() -> new ResourceNotFoundException("Service not found"));

        PricingBreakdownResponse price = pricingService.calculate(
                provider, req.estimatedHours(), req.latitude(), req.longitude());

        OffsetDateTime expiry = req.requestExpiresAt() != null
                ? req.requestExpiresAt()
                : OffsetDateTime.now().plusMinutes(DEFAULT_EXPIRY_MINUTES);

        Booking booking = Booking.builder()
                .customerId(customerId)
                .providerId(providerUserId)
                .skillId(skill.getId())
                .status(JobStatus.REQUESTED)
                .scheduledAt(req.scheduledAt())
                .estimatedHours(req.estimatedHours())
                .addressLine(req.addressLine())
                .latitude(req.latitude())
                .longitude(req.longitude())
                .taskTitle(req.taskTitle())
                .description(req.description())
                .contactName(req.contactName())
                .contactPhone(req.contactPhone())
                .requestExpiresAt(expiry)
                .basePrice(price.basePrice())
                .hourlyRate(price.hourlyRate())
                .workingHours(price.workingHours())
                .workingFee(price.workingFee())
                .travelDistanceKm(price.travelDistanceKm())
                .travelFee(price.travelFee())
                .totalPrice(price.totalPrice())
                .build();

        Booking saved = bookingRepository.save(booking);
        recordEvent(saved.getId(), saved.getStatus(), saved.getCreatedAt());
        return BookingResponse.from(saved, skill.getName());
    }

    @Transactional(readOnly = true)
    public BookingResponse getById(UUID userId, UUID id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
        if (!booking.involves(userId)) {
            throw new ForbiddenOperationException("You are not part of this booking");
        }
        return BookingResponse.from(booking, skillName(booking.getSkillId()));
    }

    @Transactional(readOnly = true)
    public List<BookingResponse> listMine(UUID userId) {
        List<Booking> bookings =
                bookingRepository.findByCustomerIdOrProviderIdOrderByCreatedAtDesc(userId, userId);
        Map<UUID, String> names = skillNames(bookings);
        return bookings.stream()
                .map(b -> BookingResponse.from(b, names.get(b.getSkillId())))
                .toList();
    }

    // ---- Job state machine (P4.3) ----

    private static final Map<JobStatus, Set<JobStatus>> ALLOWED = Map.of(
            JobStatus.REQUESTED, EnumSet.of(JobStatus.ACCEPTED, JobStatus.DECLINED, JobStatus.CANCELLED, JobStatus.EXPIRED),
            JobStatus.ACCEPTED, EnumSet.of(JobStatus.EN_ROUTE, JobStatus.CANCELLED),
            JobStatus.EN_ROUTE, EnumSet.of(JobStatus.STARTED, JobStatus.CANCELLED),
            JobStatus.STARTED, EnumSet.of(JobStatus.COMPLETED),
            JobStatus.COMPLETED, EnumSet.of(JobStatus.RATED, JobStatus.PAID),
            JobStatus.RATED, EnumSet.of(JobStatus.PAID));

    @Transactional
    public BookingResponse accept(UUID providerId, UUID id) {
        return providerAction(providerId, id, JobStatus.ACCEPTED);
    }

    @Transactional
    public BookingResponse decline(UUID providerId, UUID id) {
        return providerAction(providerId, id, JobStatus.DECLINED);
    }

    @Transactional
    public BookingResponse enRoute(UUID providerId, UUID id) {
        return providerAction(providerId, id, JobStatus.EN_ROUTE);
    }

    @Transactional
    public BookingResponse start(UUID providerId, UUID id) {
        return providerAction(providerId, id, JobStatus.STARTED);
    }

    @Transactional
    public BookingResponse complete(UUID providerId, UUID id) {
        return providerAction(providerId, id, JobStatus.COMPLETED);
    }

    /** Marks a COMPLETED job RATED once its review lands (called by the review service). */
    @Transactional
    public void markRated(UUID bookingId) {
        Booking booking = getEntity(bookingId);
        transition(booking, JobStatus.RATED);
        bookingRepository.save(booking);
        recordEvent(booking.getId(), JobStatus.RATED, OffsetDateTime.now());
    }

    /** Either party may cancel, but only before work has started. */
    @Transactional
    public BookingResponse cancel(UUID userId, UUID id, String reason) {
        Booking booking = getEntity(id);
        if (!booking.involves(userId)) {
            throw new ForbiddenOperationException("You are not part of this booking");
        }
        transition(booking, JobStatus.CANCELLED);
        booking.setCancelledBy(userId);
        booking.setCancelReason(reason);
        return saveAndRecord(booking);
    }

    private BookingResponse providerAction(UUID providerId, UUID id, JobStatus target) {
        Booking booking = getEntity(id);
        if (!booking.getProviderId().equals(providerId)) {
            throw new ForbiddenOperationException("Only the assigned provider can update this job");
        }
        transition(booking, target);
        return saveAndRecord(booking);
    }

    private void transition(Booking booking, JobStatus target) {
        if (!ALLOWED.getOrDefault(booking.getStatus(), Set.of()).contains(target)) {
            throw new IllegalArgumentException(
                    "Cannot change a %s booking to %s".formatted(booking.getStatus(), target));
        }
        OffsetDateTime now = OffsetDateTime.now();
        booking.setStatus(target);
        switch (target) {
            case ACCEPTED -> booking.setAcceptedAt(now);
            case STARTED -> booking.setStartedAt(now);
            case COMPLETED -> booking.setCompletedAt(now);
            case CANCELLED -> booking.setCancelledAt(now);
            default -> { }
        }
    }

    private Booking getEntity(UUID id) {
        return bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
    }

    private BookingResponse respond(Booking booking) {
        return BookingResponse.from(booking, skillName(booking.getSkillId()));
    }

    private BookingResponse saveAndRecord(Booking booking) {
        Booking saved = bookingRepository.save(booking);
        recordEvent(saved.getId(), saved.getStatus(), OffsetDateTime.now());
        return respond(saved);
    }

    private void recordEvent(UUID bookingId, JobStatus status, OffsetDateTime at) {
        OffsetDateTime when = (at != null) ? at : OffsetDateTime.now();
        eventRepository.save(BookingStatusEvent.builder()
                .bookingId(bookingId).status(status).at(when).build());
        events.publishEvent(new BookingStatusChangedEvent(bookingId, status, when));
    }

    /** Ordered status history for a booking (participants only). */
    @Transactional(readOnly = true)
    public List<StatusEventResponse> timeline(UUID userId, UUID id) {
        Booking booking = getEntity(id);
        if (!booking.involves(userId)) {
            throw new ForbiddenOperationException("You are not part of this booking");
        }
        return eventRepository.findByBookingIdOrderByAtAsc(id).stream()
                .map(StatusEventResponse::from)
                .toList();
    }

    private String skillName(UUID skillId) {
        return skillRepository.findById(skillId).map(Skill::getName).orElse(null);
    }

    private Map<UUID, String> skillNames(List<Booking> bookings) {
        Set<UUID> ids = bookings.stream().map(Booking::getSkillId).collect(Collectors.toSet());
        return skillRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(Skill::getId, Skill::getName));
    }
}
