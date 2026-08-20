package com.giggo.backend.provider.api.dto;

import java.time.LocalTime;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** Replace a provider's weekly working hours (P2.10). One entry per working day. */
public record SetAvailabilityRequest(
        @NotNull List<@Valid Entry> days
) {
    public record Entry(
            @Min(1) @Max(7) int dayOfWeek,
            @NotNull LocalTime startTime,
            @NotNull LocalTime endTime
    ) {}
}
