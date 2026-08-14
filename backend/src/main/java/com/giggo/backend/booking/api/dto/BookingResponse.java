package com.giggo.backend.booking.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;

public record BookingResponse(
        UUID id,
        UUID customerId,
        UUID providerId,
        UUID skillId,
        String skillName,
        JobStatus status,
        OffsetDateTime scheduledAt,
        BigDecimal estimatedHours,
        String addressLine,
        Double latitude,
        Double longitude,
        String taskTitle,
        String description,
        String contactName,
        String contactPhone,
        OffsetDateTime requestExpiresAt,
        BigDecimal basePrice,
        BigDecimal hourlyRate,
        BigDecimal workingHours,
        BigDecimal workingFee,
        BigDecimal travelDistanceKm,
        BigDecimal travelFee,
        BigDecimal totalPrice,
        OffsetDateTime createdAt
) {
    public static BookingResponse from(Booking b, String skillName) {
        return new BookingResponse(
                b.getId(), b.getCustomerId(), b.getProviderId(), b.getSkillId(), skillName,
                b.getStatus(), b.getScheduledAt(), b.getEstimatedHours(), b.getAddressLine(),
                b.getLatitude(), b.getLongitude(), b.getTaskTitle(), b.getDescription(),
                b.getContactName(), b.getContactPhone(), b.getRequestExpiresAt(),
                b.getBasePrice(), b.getHourlyRate(), b.getWorkingHours(), b.getWorkingFee(),
                b.getTravelDistanceKm(), b.getTravelFee(), b.getTotalPrice(), b.getCreatedAt());
    }
}
