package com.giggo.backend.booking.api.dto;

import java.time.OffsetDateTime;

import com.giggo.backend.booking.domain.BookingStatusEvent;
import com.giggo.backend.booking.domain.JobStatus;

public record StatusEventResponse(JobStatus status, OffsetDateTime at) {
    public static StatusEventResponse from(BookingStatusEvent e) {
        return new StatusEventResponse(e.getStatus(), e.getAt());
    }
}
