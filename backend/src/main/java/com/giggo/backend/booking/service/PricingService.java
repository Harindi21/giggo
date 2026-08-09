package com.giggo.backend.booking.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.api.dto.QuoteRequest;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

import lombok.RequiredArgsConstructor;

/**
 * Dynamic pricing (thesis §5.1.1):
 * total = base fee + (estimated hours × hourly rate) + (travel distance × per-km rate).
 */
@Service
@RequiredArgsConstructor
public class PricingService {

    private final ProviderProfileRepository providerRepository;
    private final DistanceCalculator distanceCalculator;

    @Value("${giggo.pricing.travel-fee-per-km:50}")
    private BigDecimal travelFeePerKm;

    @Transactional(readOnly = true)
    public PricingBreakdownResponse quote(QuoteRequest req) {
        ProviderProfile provider = providerRepository.findById(req.providerId())
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found"));
        return calculate(provider, req.estimatedHours(), req.latitude(), req.longitude());
    }

    /**
     * Computes a breakdown for an already-loaded provider. Reused by booking
     * creation (P4.2) so pricing is identical to the quote the customer saw.
     */
    public PricingBreakdownResponse calculate(ProviderProfile provider, BigDecimal estimatedHours,
                                              Double customerLat, Double customerLng) {
        BigDecimal base = nz(provider.getBasePrice());
        BigDecimal hourly = nz(provider.getHourlyRate());
        BigDecimal workingFee = hourly.multiply(estimatedHours);

        BigDecimal distanceKm = BigDecimal.ZERO;
        if (customerLat != null && customerLng != null
                && provider.getLatitude() != null && provider.getLongitude() != null) {
            double d = distanceCalculator.distanceKm(
                    provider.getLatitude(), provider.getLongitude(), customerLat, customerLng);
            distanceKm = BigDecimal.valueOf(d);
        }
        BigDecimal travelFee = distanceKm.multiply(travelFeePerKm);
        BigDecimal total = base.add(workingFee).add(travelFee);

        return new PricingBreakdownResponse(
                money(base),
                estimatedHours.setScale(2, RoundingMode.HALF_UP),
                money(hourly),
                money(workingFee),
                distanceKm.setScale(2, RoundingMode.HALF_UP),
                money(travelFeePerKm),
                money(travelFee),
                money(total)
        );
    }

    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    private static BigDecimal money(BigDecimal v) {
        return v.setScale(2, RoundingMode.HALF_UP);
    }

    // Package-private hook for tests to fix the per-km rate without Spring context.
    void setTravelFeePerKm(BigDecimal value) {
        this.travelFeePerKm = value;
    }
}
