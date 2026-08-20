package com.giggo.backend.provider.api.dto;

import java.time.LocalTime;

import com.giggo.backend.provider.domain.WorkingHour;

/** A provider's working interval for one day (P2.10). dayOfWeek: 1=Mon … 7=Sun. */
public record WorkingHourResponse(
        int dayOfWeek,
        LocalTime startTime,
        LocalTime endTime
) {
    public static WorkingHourResponse from(WorkingHour w) {
        return new WorkingHourResponse(w.getDayOfWeek(), w.getStartTime(), w.getEndTime());
    }
}
