package com.giggo.backend.realtime.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.giggo.backend.booking.service.DistanceCalculator;
import com.giggo.backend.realtime.service.EtaCalculator.EtaResult;

@DisplayName("HaversineEtaCalculator")
class HaversineEtaCalculatorTest {

    private HaversineEtaCalculator calc;

    @BeforeEach
    void setUp() {
        // Stub distance = 10 km regardless of coordinates.
        DistanceCalculator fixed10km = (a, b, c, d) -> 10.0;
        calc = new HaversineEtaCalculator(fixed10km);
        calc.setAverageSpeedKmh(30.0);
    }

    @Test
    @DisplayName("uses the average speed when live speed is unknown")
    void usesAverageWhenNoSpeed() {
        EtaResult r = calc.estimate(0, 0, 1, 1, null);
        assertThat(r.speedKmhUsed()).isEqualTo(30.0);
        assertThat(r.etaMinutes()).isEqualTo(20); // 10 km / 30 km/h = 20 min
        assertThat(r.distanceKm()).isEqualTo(10.0);
    }

    @Test
    @DisplayName("uses the live speed when it's meaningful")
    void usesLiveSpeed() {
        EtaResult r = calc.estimate(0, 0, 1, 1, 60.0);
        assertThat(r.speedKmhUsed()).isEqualTo(60.0);
        assertThat(r.etaMinutes()).isEqualTo(10); // 10 km / 60 km/h = 10 min
    }

    @Test
    @DisplayName("ignores a near-zero (stopped) speed and falls back to the average")
    void ignoresStoppedSpeed() {
        EtaResult r = calc.estimate(0, 0, 1, 1, 1.0);
        assertThat(r.speedKmhUsed()).isEqualTo(30.0);
    }
}
