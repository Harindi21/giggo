package com.giggo.backend.booking.api.dto;

import java.math.BigDecimal;
import java.util.UUID;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

/**
 * Request for a price estimate. Customer location is optional; when omitted (or
 * the provider has no coordinates) the travel fee is zero.
 */
public record QuoteRequest(
        @NotNull UUID providerId,
        @NotNull @DecimalMin("0.25") @DecimalMax("24.0") BigDecimal estimatedHours,
        Double latitude,
        Double longitude
) {}
