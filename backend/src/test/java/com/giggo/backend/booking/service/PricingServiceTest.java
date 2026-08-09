package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.api.dto.QuoteRequest;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("PricingService")
class PricingServiceTest {

    @Mock
    private ProviderProfileRepository providerRepository;
    @Mock
    private DistanceCalculator distanceCalculator;

    private PricingService pricingService;

    @BeforeEach
    void setUp() {
        pricingService = new PricingService(providerRepository, distanceCalculator);
        pricingService.setTravelFeePerKm(new BigDecimal("50"));
    }

    private ProviderProfile provider(String base, String hourly, boolean withCoords) {
        return ProviderProfile.builder()
                .basePrice(new BigDecimal(base))
                .hourlyRate(new BigDecimal(hourly))
                .latitude(withCoords ? 6.9271 : null)
                .longitude(withCoords ? 79.8612 : null)
                .build();
    }

    @Test
    @DisplayName("total = base + hours*hourly + distance*perKm")
    void fullQuote() {
        UUID id = UUID.randomUUID();
        when(providerRepository.findById(id)).thenReturn(Optional.of(provider("500", "500", true)));
        when(distanceCalculator.distanceKm(anyDouble(), anyDouble(), anyDouble(), anyDouble())).thenReturn(5.0);

        PricingBreakdownResponse r = pricingService.quote(
                new QuoteRequest(id, new BigDecimal("2"), 6.90, 79.90));

        assertThat(r.basePrice()).isEqualByComparingTo("500");
        assertThat(r.workingFee()).isEqualByComparingTo("1000");   // 2 * 500
        assertThat(r.travelDistanceKm()).isEqualByComparingTo("5");
        assertThat(r.travelFee()).isEqualByComparingTo("250");     // 5 * 50
        assertThat(r.totalPrice()).isEqualByComparingTo("1750");   // 500 + 1000 + 250
    }

    @Test
    @DisplayName("no customer location => zero travel fee and no distance call")
    void noLocationNoTravel() {
        UUID id = UUID.randomUUID();
        when(providerRepository.findById(id)).thenReturn(Optional.of(provider("500", "500", true)));

        PricingBreakdownResponse r = pricingService.quote(
                new QuoteRequest(id, new BigDecimal("1.5"), null, null));

        assertThat(r.travelFee()).isEqualByComparingTo("0");
        assertThat(r.workingFee()).isEqualByComparingTo("750");    // 1.5 * 500
        assertThat(r.totalPrice()).isEqualByComparingTo("1250");   // 500 + 750
        verify(distanceCalculator, never()).distanceKm(anyDouble(), anyDouble(), anyDouble(), anyDouble());
    }

    @Test
    @DisplayName("provider without coordinates => zero travel fee")
    void providerWithoutCoords() {
        UUID id = UUID.randomUUID();
        when(providerRepository.findById(id)).thenReturn(Optional.of(provider("400", "300", false)));

        PricingBreakdownResponse r = pricingService.quote(
                new QuoteRequest(id, new BigDecimal("1"), 6.90, 79.90));

        assertThat(r.travelFee()).isEqualByComparingTo("0");
        assertThat(r.totalPrice()).isEqualByComparingTo("700");    // 400 + 300
        verify(distanceCalculator, never()).distanceKm(anyDouble(), anyDouble(), anyDouble(), anyDouble());
    }

    @Test
    @DisplayName("unknown provider throws ResourceNotFoundException")
    void unknownProvider() {
        UUID id = UUID.randomUUID();
        when(providerRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> pricingService.quote(new QuoteRequest(id, new BigDecimal("1"), null, null)))
                .isInstanceOf(ResourceNotFoundException.class);
        verifyNoInteractions(distanceCalculator);
    }
}
