package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@DisplayName("HaversineDistanceCalculator")
class HaversineDistanceCalculatorTest {

    private final HaversineDistanceCalculator calc = new HaversineDistanceCalculator();

    @Test
    @DisplayName("returns 0 for identical points")
    void samePointIsZero() {
        assertThat(calc.distanceKm(6.9271, 79.8612, 6.9271, 79.8612)).isZero();
    }

    @Test
    @DisplayName("Colombo to Kandy is roughly 94 km straight line")
    void colomboToKandy() {
        double km = calc.distanceKm(6.9271, 79.8612, 7.2906, 80.6337);
        assertThat(km).isBetween(90.0, 100.0);
    }

    @Test
    @DisplayName("is symmetric")
    void symmetric() {
        double ab = calc.distanceKm(6.9271, 79.8612, 7.2906, 80.6337);
        double ba = calc.distanceKm(7.2906, 80.6337, 6.9271, 79.8612);
        assertThat(ab).isEqualTo(ba);
    }
}
