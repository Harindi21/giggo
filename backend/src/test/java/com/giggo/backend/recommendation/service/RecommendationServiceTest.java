package com.giggo.backend.recommendation.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.provider.api.dto.ProviderCardResponse;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.recommendation.service.RecommendationClient.RecResponse;
import com.giggo.backend.recommendation.service.RecommendationClient.RecResult;
import com.giggo.backend.user.domain.User;

@ExtendWith(MockitoExtension.class)
@DisplayName("RecommendationService")
class RecommendationServiceTest {

    @Mock ProviderProfileRepository profileRepository;
    @Mock BookingRepository bookingRepository;
    @Mock RecommendationClient client;

    private RecommendationService service;

    private final UUID customerId = UUID.randomUUID();
    private ProviderProfile p1;
    private ProviderProfile p2;

    @BeforeEach
    void setUp() {
        service = new RecommendationService(profileRepository, bookingRepository, client);
        p1 = profile("Alice", new BigDecimal("4.8"), 40);
        p2 = profile("Bob", new BigDecimal("3.5"), 5);
        lenient().when(bookingRepository.findAll()).thenReturn(List.of());
        // Repository returns providers pre-sorted by quality (also the fallback order).
        lenient().when(profileRepository.search(null, null, null, null))
                .thenReturn(List.of(p1, p2));
    }

    private ProviderProfile profile(String name, BigDecimal rating, int count) {
        User u = User.builder().id(UUID.randomUUID()).fullName(name).build();
        return ProviderProfile.builder()
                .id(UUID.randomUUID())
                .user(u)
                .avgRating(rating)
                .ratingCount(count)
                .jobsCompleted(count)
                .basePrice(BigDecimal.ZERO)
                .hourlyRate(BigDecimal.ZERO)
                .build();
    }

    @Test
    @DisplayName("orders provider cards by the ML service ranking")
    void ranksByMlResult() {
        when(client.recommend(any())).thenReturn(Optional.of(new RecResponse(
                "hybrid",
                List.of(
                        new RecResult(p2.getId().toString(), 0.9, "co-booked"),
                        new RecResult(p1.getId().toString(), 0.5, "rated")))));

        List<ProviderCardResponse> out = service.recommendFor(customerId, 10, null, null);

        assertThat(out).extracting(ProviderCardResponse::id)
                .containsExactly(p2.getId(), p1.getId());
    }

    @Test
    @DisplayName("falls back to quality order when the ML service is unavailable")
    void fallsBackToQuality() {
        when(client.recommend(any())).thenReturn(Optional.empty());

        List<ProviderCardResponse> out = service.recommendFor(customerId, 10, null, null);

        assertThat(out).extracting(ProviderCardResponse::id)
                .containsExactly(p1.getId(), p2.getId());
    }
}
