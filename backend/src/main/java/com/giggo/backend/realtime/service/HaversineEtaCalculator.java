package com.giggo.backend.realtime.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.giggo.backend.booking.service.DistanceCalculator;

import lombok.RequiredArgsConstructor;

/**
 * ETA from straight-line distance and speed. Uses the provider's live speed when
 * it's meaningful, otherwise a configurable average urban speed. Reuses the
 * shared {@link DistanceCalculator} (Haversine) from the pricing engine (P4.1).
 */
@Component
@RequiredArgsConstructor
public class HaversineEtaCalculator implements EtaCalculator {

    /** Below this, a reported speed is treated as "stopped" and ignored. */
    private static final double MIN_USEFUL_SPEED_KMH = 5.0;

    private final DistanceCalculator distanceCalculator;

    @Value("${giggo.tracking.average-speed-kmh:25}")
    private double averageSpeedKmh;

    @Override
    public EtaResult estimate(double fromLat, double fromLng, double toLat, double toLng, Double currentSpeedKmh) {
        double km = distanceCalculator.distanceKm(fromLat, fromLng, toLat, toLng);
        double speed = (currentSpeedKmh != null && currentSpeedKmh >= MIN_USEFUL_SPEED_KMH)
                ? currentSpeedKmh
                : averageSpeedKmh;
        int minutes = (int) Math.ceil((km / speed) * 60.0);
        double roundedKm = BigDecimal.valueOf(km).setScale(2, RoundingMode.HALF_UP).doubleValue();
        return new EtaResult(roundedKm, minutes, speed);
    }

    // Test hook to set the average without a Spring context.
    void setAverageSpeedKmh(double value) {
        this.averageSpeedKmh = value;
    }
}
