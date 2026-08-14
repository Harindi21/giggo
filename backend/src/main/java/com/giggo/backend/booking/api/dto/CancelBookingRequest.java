package com.giggo.backend.booking.api.dto;

import jakarta.validation.constraints.Size;

/** Optional reason when cancelling a booking. */
public record CancelBookingRequest(@Size(max = 500) String reason) {}
