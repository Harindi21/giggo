package com.giggo.backend.booking.api.dto;

import java.math.BigDecimal;

/** Transparent, itemised price breakdown (mockup: Base Fee / Travel / Work fee / Total). */
public record PricingBreakdownResponse(
        BigDecimal basePrice,
        BigDecimal workingHours,
        BigDecimal hourlyRate,
        BigDecimal workingFee,
        BigDecimal travelDistanceKm,
        BigDecimal travelFeePerKm,
        BigDecimal travelFee,
        BigDecimal totalPrice
) {}
