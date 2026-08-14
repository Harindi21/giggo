package com.giggo.backend.booking.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** Booking form (mockup image32): provider + service, schedule, task and contact. */
public record CreateBookingRequest(
        @NotNull UUID providerId,          // provider profile id (from discovery)
        @NotNull UUID skillId,             // the service being booked
        @NotNull OffsetDateTime scheduledAt,
        @NotNull @DecimalMin("0.25") @DecimalMax("24.0") BigDecimal estimatedHours,
        @Size(max = 255) String addressLine,
        Double latitude,
        Double longitude,
        @Size(max = 150) String taskTitle,
        @Size(max = 1000) String description,
        @Size(max = 120) String contactName,
        @Size(max = 30) String contactPhone,
        OffsetDateTime requestExpiresAt    // optional; defaults to +30 min
) {}
