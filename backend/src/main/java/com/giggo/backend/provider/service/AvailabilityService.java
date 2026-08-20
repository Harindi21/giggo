package com.giggo.backend.provider.service;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.provider.api.dto.SetAvailabilityRequest;
import com.giggo.backend.provider.domain.WorkingHour;
import com.giggo.backend.provider.repository.WorkingHourRepository;

import lombok.RequiredArgsConstructor;

/**
 * Provider weekly working hours (P2.10) and the availability check used when a
 * booking is created (P3.3). A provider with no configured hours is treated as
 * always available (backwards-compatible).
 */
@Service
@RequiredArgsConstructor
public class AvailabilityService {

    private final WorkingHourRepository repository;

    @Transactional(readOnly = true)
    public List<WorkingHour> getWorkingHours(UUID providerId) {
        return repository.findByProviderIdOrderByDayOfWeekAsc(providerId);
    }

    /** Replace a provider's weekly hours in one shot. */
    @Transactional
    public List<WorkingHour> setWorkingHours(UUID providerId, List<SetAvailabilityRequest.Entry> entries) {
        Set<Integer> seen = new HashSet<>();
        for (SetAvailabilityRequest.Entry e : entries) {
            if (!e.startTime().isBefore(e.endTime())) {
                throw new IllegalArgumentException(
                        "Start time must be before end time (day " + e.dayOfWeek() + ").");
            }
            if (!seen.add(e.dayOfWeek())) {
                throw new IllegalArgumentException("Only one interval per day is allowed (day " + e.dayOfWeek() + ").");
            }
        }
        repository.deleteByProviderId(providerId);
        repository.flush(); // apply the delete before inserting, for the unique (provider, day) constraint
        return entries.stream()
                .map(e -> repository.save(WorkingHour.builder()
                        .providerId(providerId)
                        .dayOfWeek(e.dayOfWeek())
                        .startTime(e.startTime())
                        .endTime(e.endTime())
                        .build()))
                .toList();
    }

    /**
     * Enforce that {@code scheduledAt} for {@code hours} falls within the provider's
     * configured working hours (P3.3). No-op when the provider has set none.
     */
    @Transactional(readOnly = true)
    public void assertWithinWorkingHours(UUID providerId, OffsetDateTime scheduledAt, BigDecimal hours) {
        List<WorkingHour> configured = repository.findByProviderIdOrderByDayOfWeekAsc(providerId);
        if (configured.isEmpty()) {
            return;
        }
        int day = scheduledAt.getDayOfWeek().getValue();
        WorkingHour interval = configured.stream()
                .filter(w -> w.getDayOfWeek() == day)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("The provider isn't available on that day."));

        int startMin = minutesOfDay(scheduledAt.toLocalTime());
        int endMin = startMin + hours.multiply(BigDecimal.valueOf(60)).intValue();
        if (startMin < minutesOfDay(interval.getStartTime()) || endMin > minutesOfDay(interval.getEndTime())) {
            throw new IllegalArgumentException("The provider isn't available at that time.");
        }
    }

    private static int minutesOfDay(LocalTime t) {
        return t.getHour() * 60 + t.getMinute();
    }
}
