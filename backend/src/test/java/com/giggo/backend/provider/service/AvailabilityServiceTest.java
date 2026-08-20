package com.giggo.backend.provider.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.provider.api.dto.SetAvailabilityRequest;
import com.giggo.backend.provider.domain.WorkingHour;
import com.giggo.backend.provider.repository.WorkingHourRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("AvailabilityService")
class AvailabilityServiceTest {

    @Mock WorkingHourRepository repository;

    private AvailabilityService service;

    private final UUID providerId = UUID.randomUUID();
    // A fixed 10:00 slot; its day-of-week drives the fixtures below.
    private final OffsetDateTime slot =
            OffsetDateTime.of(2026, 8, 24, 10, 0, 0, 0, ZoneOffset.ofHoursMinutes(5, 30));

    @BeforeEach
    void setUp() {
        service = new AvailabilityService(repository);
        lenient().when(repository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private WorkingHour hoursFor(int day, int startHour, int endHour) {
        return WorkingHour.builder().providerId(providerId).dayOfWeek(day)
                .startTime(LocalTime.of(startHour, 0)).endTime(LocalTime.of(endHour, 0)).build();
    }

    private SetAvailabilityRequest.Entry entry(int day, int startHour, int endHour) {
        return new SetAvailabilityRequest.Entry(day, LocalTime.of(startHour, 0), LocalTime.of(endHour, 0));
    }

    @Test
    @DisplayName("setWorkingHours replaces the week and saves each entry")
    void setReplaces() {
        List<WorkingHour> saved = service.setWorkingHours(providerId, List.of(entry(1, 9, 17), entry(2, 10, 18)));
        assertThat(saved).hasSize(2);
    }

    @Test
    @DisplayName("rejects an interval whose start is not before its end")
    void rejectsBadInterval() {
        assertThatThrownBy(() -> service.setWorkingHours(providerId, List.of(entry(1, 17, 9))))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("rejects two intervals for the same day")
    void rejectsDuplicateDay() {
        assertThatThrownBy(() -> service.setWorkingHours(providerId, List.of(entry(1, 9, 12), entry(1, 13, 17))))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("no configured hours -> always available")
    void unconfiguredAllows() {
        when(repository.findByProviderIdOrderByDayOfWeekAsc(providerId)).thenReturn(List.of());
        assertThatCode(() -> service.assertWithinWorkingHours(providerId, slot, new BigDecimal("2")))
                .doesNotThrowAnyException();
    }

    @Test
    @DisplayName("a slot inside the working interval is allowed")
    void withinAllows() {
        int day = slot.getDayOfWeek().getValue();
        when(repository.findByProviderIdOrderByDayOfWeekAsc(providerId)).thenReturn(List.of(hoursFor(day, 9, 17)));
        assertThatCode(() -> service.assertWithinWorkingHours(providerId, slot, new BigDecimal("2")))
                .doesNotThrowAnyException(); // 10:00–12:00 within 09:00–17:00
    }

    @Test
    @DisplayName("a slot that runs past closing time is rejected")
    void pastClosingRejected() {
        int day = slot.getDayOfWeek().getValue();
        when(repository.findByProviderIdOrderByDayOfWeekAsc(providerId)).thenReturn(List.of(hoursFor(day, 9, 11)));
        assertThatThrownBy(() -> service.assertWithinWorkingHours(providerId, slot, new BigDecimal("2")))
                .isInstanceOf(IllegalArgumentException.class); // 10:00–12:00 exceeds 11:00
    }

    @Test
    @DisplayName("a day with no configured interval is rejected")
    void closedDayRejected() {
        int otherDay = slot.getDayOfWeek().getValue() % 7 + 1; // a different day
        when(repository.findByProviderIdOrderByDayOfWeekAsc(providerId)).thenReturn(List.of(hoursFor(otherDay, 9, 17)));
        assertThatThrownBy(() -> service.assertWithinWorkingHours(providerId, slot, new BigDecimal("2")))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
