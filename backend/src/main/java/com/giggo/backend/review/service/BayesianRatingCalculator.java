package com.giggo.backend.review.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Bayesian average (thesis §5.1.1) — the same idea IMDb uses to rank movies.
 * A provider's raw average is blended with a neutral prior; the fewer reviews they
 * have, the more the score is pulled toward the prior, so 2 five-star reviews don't
 * outrank 300 reviews averaging 4.7.
 *
 * <pre>bayesian = (n/(n+m)) * rawAverage + (m/(n+m)) * prior</pre>
 * with prior = 3.0 (neutral) and smoothing m = 5.
 */
@Component
public class BayesianRatingCalculator {

    private static final int PRECISION = 10;

    @Value("${giggo.rating.bayesian-prior:3.0}")
    private BigDecimal prior;
    @Value("${giggo.rating.bayesian-smoothing:5}")
    private int smoothing;

    public BigDecimal compute(int count, BigDecimal rawAverage) {
        if (count <= 0 || rawAverage == null) {
            return prior.setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal n = BigDecimal.valueOf(count);
        BigDecimal m = BigDecimal.valueOf(smoothing);
        BigDecimal denom = n.add(m);
        BigDecimal fromReviews = n.divide(denom, PRECISION, RoundingMode.HALF_UP).multiply(rawAverage);
        BigDecimal fromPrior = m.divide(denom, PRECISION, RoundingMode.HALF_UP).multiply(prior);
        return fromReviews.add(fromPrior).setScale(2, RoundingMode.HALF_UP);
    }

    public BigDecimal compute(List<BigDecimal> ratings) {
        if (ratings == null || ratings.isEmpty()) {
            return prior.setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal sum = ratings.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal average = sum.divide(BigDecimal.valueOf(ratings.size()), PRECISION, RoundingMode.HALF_UP);
        return compute(ratings.size(), average);
    }
}
