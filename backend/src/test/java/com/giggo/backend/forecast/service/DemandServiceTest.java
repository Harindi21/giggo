package com.giggo.backend.forecast.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.forecast.api.dto.CategoryDemandResponse;
import com.giggo.backend.forecast.service.ForecastClient.ForecastResult;
import com.giggo.backend.provider.domain.Category;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("DemandService")
class DemandServiceTest {

    @Mock BookingRepository bookingRepository;
    @Mock SkillRepository skillRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock ForecastClient forecastClient;

    private DemandService service;

    private final UUID userId = UUID.randomUUID();
    private final UUID skillId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new DemandService(bookingRepository, skillRepository, providerRepository, forecastClient);
    }

    private void wireData() {
        Category plumbing = Category.builder().id(UUID.randomUUID()).name("Plumbing").active(true).build();
        Skill skill = Skill.builder().id(skillId).name("Pipe repair").active(true).category(plumbing).build();
        when(skillRepository.findAll()).thenReturn(List.of(skill));

        OffsetDateTime now = OffsetDateTime.now();
        Booking b1 = Booking.builder().id(UUID.randomUUID()).skillId(skillId).createdAt(now).build();
        Booking b2 = Booking.builder().id(UUID.randomUUID()).skillId(skillId).createdAt(now).build();
        when(bookingRepository.findByCreatedAtAfter(any())).thenReturn(List.of(b1, b2));

        ProviderProfile profile = ProviderProfile.builder().id(UUID.randomUUID()).build();
        profile.setSkills(Set.of(skill));
        when(providerRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
    }

    @Test
    @DisplayName("builds a weekly series per category and uses the ML forecast")
    void usesMlForecast() {
        wireData();
        when(forecastClient.forecast(any(), anyInt()))
                .thenReturn(Optional.of(new ForecastResult(List.of(5.0), "rising", "linear-trend")));

        List<CategoryDemandResponse> out = service.demandForProvider(userId);

        assertThat(out).singleElement().satisfies(d -> {
            assertThat(d.category()).isEqualTo("Plumbing");
            assertThat(d.weeklyCounts()).hasSize(8);
            assertThat(d.weeklyCounts().get(7)).isEqualTo(2); // this week
            assertThat(d.forecastNextWeek()).isEqualTo(5);
            assertThat(d.trend()).isEqualTo("rising");
        });
    }

    @Test
    @DisplayName("falls back to a naive projection when the ML service is unavailable")
    void fallsBackWhenMlDown() {
        wireData();
        when(forecastClient.forecast(any(), anyInt())).thenReturn(Optional.empty());

        List<CategoryDemandResponse> out = service.demandForProvider(userId);

        assertThat(out).singleElement().satisfies(d -> {
            assertThat(d.category()).isEqualTo("Plumbing");
            assertThat(d.forecastNextWeek()).isGreaterThanOrEqualTo(0);
            assertThat(d.trend()).isIn("rising", "falling", "steady");
        });
    }
}
