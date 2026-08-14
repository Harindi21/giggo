package com.giggo.backend.review.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

@DisplayName("BayesianRatingCalculator (prior 3.0, m 5)")
class BayesianRatingCalculatorTest {

    private BayesianRatingCalculator calc;

    @BeforeEach
    void setUp() {
        calc = new BayesianRatingCalculator();
        ReflectionTestUtils.setField(calc, "prior", new BigDecimal("3.0"));
        ReflectionTestUtils.setField(calc, "smoothing", 5);
    }

    @Test
    @DisplayName("no reviews -> the neutral prior")
    void noReviews() {
        assertThat(calc.compute(0, null)).isEqualByComparingTo("3.00");
        assertThat(calc.compute(0, new BigDecimal("5.0"))).isEqualByComparingTo("3.00");
        assertThat(calc.compute(List.of())).isEqualByComparingTo("3.00");
    }

    @Test
    @DisplayName("2 five-star reviews are pulled toward the prior")
    void fewReviewsPulledToPrior() {
        // (2/7)*5 + (5/7)*3 = 3.57
        assertThat(calc.compute(2, new BigDecimal("5.0"))).isEqualByComparingTo("3.57");
    }

    @Test
    @DisplayName("many reviews are almost entirely the real average")
    void manyReviewsTrustReal() {
        // (100/105)*4.8 + (5/105)*3 = 4.71
        assertThat(calc.compute(100, new BigDecimal("4.8"))).isEqualByComparingTo("4.71");
    }

    @Test
    @DisplayName("five 5-star reviews -> 4.00 (50% real, 50% prior)")
    void fromList() {
        var fives = List.of(new BigDecimal("5"), new BigDecimal("5"), new BigDecimal("5"),
                new BigDecimal("5"), new BigDecimal("5"));
        assertThat(calc.compute(fives)).isEqualByComparingTo("4.00");
    }
}
