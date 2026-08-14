package com.giggo.backend.booking.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.api.dto.CreateBookingRequest;
import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
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
    private final ProviderProfileRepository providerRepository;
    private final SkillRepository skillRepository;
    private final PricingService pricingService;

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

        return BookingResponse.from(bookingRepository.save(booking), skill.getName());
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

    private String skillName(UUID skillId) {
        return skillRepository.findById(skillId).map(Skill::getName).orElse(null);
    }

    private Map<UUID, String> skillNames(List<Booking> bookings) {
        Set<UUID> ids = bookings.stream().map(Booking::getSkillId).collect(Collectors.toSet());
        return skillRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(Skill::getId, Skill::getName));
    }
}
