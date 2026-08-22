package com.giggo.backend.review.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.review.api.dto.AdminReviewResponse;
import com.giggo.backend.review.api.dto.CreateReviewRequest;
import com.giggo.backend.review.api.dto.RatingBreakdownResponse;
import com.giggo.backend.review.api.dto.ReviewResponse;
import com.giggo.backend.review.domain.Review;
import com.giggo.backend.review.repository.RatingBreakdownProjection;
import com.giggo.backend.review.repository.ReviewRepository;
import com.giggo.backend.review.service.SentimentClient.SentimentResult;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Review submission (P6.1): a customer rates a completed job; the text is scored by
 * the NLP service (P6.2) and blended with the star rating into an enhanced rating,
 * which nudges the provider's aggregate. The job moves COMPLETED -> RATED.
 */
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookingRepository bookingRepository;
    private final ProviderProfileRepository providerRepository;
    private final UserRepository userRepository;
    private final SentimentClient sentimentClient;
    private final BookingService bookingService;
    private final BayesianRatingCalculator bayesianCalculator;

    @Value("${giggo.rating.star-weight:0.6}")
    private BigDecimal starWeight;
    @Value("${giggo.rating.text-weight:0.4}")
    private BigDecimal textWeight;

    @Transactional
    public ReviewResponse submit(UUID customerId, UUID bookingId, CreateReviewRequest req) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
        if (!booking.getCustomerId().equals(customerId)) {
            throw new ForbiddenOperationException("Only the customer can review this job");
        }
        if (reviewRepository.existsByBookingId(bookingId)) {
            throw new DuplicateResourceException("This job has already been reviewed");
        }
        if (booking.getStatus() != JobStatus.COMPLETED) {
            throw new IllegalArgumentException("You can only review a completed job");
        }
        // Anti-fraud (P6.4): the same customer posting identical text across jobs is a
        // copy-paste spam signal — reject it before it skews a provider's rating.
        if (req.body() != null && !req.body().isBlank()
                && reviewRepository.existsByCustomerIdAndBody(customerId, req.body())) {
            throw new DuplicateResourceException(
                    "This looks like a duplicate review. Please write about this specific job.");
        }

        Optional<SentimentResult> sentiment = sentimentClient.analyze(req.body());
        BigDecimal enhanced = enhancedRating(req.stars(), sentiment);

        Review review = Review.builder()
                .bookingId(bookingId)
                .customerId(customerId)
                .providerId(booking.getProviderId())
                .stars(req.stars())
                .serviceRating(req.serviceRating())
                .punctualityRating(req.punctualityRating())
                .valueRating(req.valueRating())
                .body(req.body())
                .enhancedRating(enhanced)
                .build();
        sentiment.ifPresent(s -> {
            review.setSentimentLabel(s.label());
            review.setSentimentScore(BigDecimal.valueOf(s.score()));
            review.setSentimentStar(s.starRating());
            review.setSentimentConfidence(BigDecimal.valueOf(s.confidence()));
            review.setSentimentEmotion(s.emotion());
            review.setSentimentLanguage(s.language());
        });
        Review saved = reviewRepository.save(review);

        bookingService.markRated(bookingId);
        adjustProviderAggregate(booking.getProviderId(), enhanced, 1);

        return ReviewResponse.from(saved, reviewerName(customerId));
    }

    // ---- Moderation (P6.5) ----

    /** A user reports a review; surfaces it in the admin queue. */
    @Transactional
    public Review report(UUID reviewId) {
        Review review = get(reviewId);
        review.setReportCount(review.getReportCount() + 1);
        return reviewRepository.save(review);
    }

    @Transactional(readOnly = true)
    public List<AdminReviewResponse> adminList(boolean reportedOnly) {
        List<Review> reviews = reportedOnly
                ? reviewRepository.findTop100ByReportCountGreaterThanOrderByReportCountDesc(0)
                : reviewRepository.findTop100ByOrderByCreatedAtDesc();
        Map<UUID, String> names = reviewerNames(reviews);
        return reviews.stream()
                .map(r -> AdminReviewResponse.from(r, names.get(r.getCustomerId())))
                .toList();
    }

    /** Hide a review: drop it from listings and remove it from the provider's rating. */
    @Transactional
    public Review hide(UUID reviewId, String reason) {
        Review review = get(reviewId);
        if (review.isHidden()) {
            return review;
        }
        review.setHidden(true);
        review.setModerationReason(reason);
        Review saved = reviewRepository.save(review);
        adjustProviderAggregate(review.getProviderId(), safe(review.getEnhancedRating()), -1);
        return saved;
    }

    /** Restore a hidden review and re-add its contribution to the rating. */
    @Transactional
    public Review restore(UUID reviewId) {
        Review review = get(reviewId);
        if (!review.isHidden()) {
            return review;
        }
        review.setHidden(false);
        review.setModerationReason(null);
        Review saved = reviewRepository.save(review);
        adjustProviderAggregate(review.getProviderId(), safe(review.getEnhancedRating()), 1);
        return saved;
    }

    private Review get(UUID id) {
        return reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found"));
    }

    private static BigDecimal safe(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    /** Reviews for a provider, identified by their provider-profile id (as in discovery). */
    @Transactional(readOnly = true)
    public List<ReviewResponse> listForProviderProfile(UUID providerProfileId) {
        ProviderProfile profile = providerRepository.findById(providerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found"));
        UUID providerUserId = profile.getUser().getId();
        List<Review> reviews =
                reviewRepository.findByProviderIdAndHiddenFalseOrderByCreatedAtDesc(providerUserId);
        Map<UUID, String> names = reviewerNames(reviews);
        return reviews.stream()
                .map(r -> ReviewResponse.from(r, names.get(r.getCustomerId())))
                .toList();
    }

    /** Per-dimension rating averages for a provider (P6.6). */
    @Transactional(readOnly = true)
    public RatingBreakdownResponse ratingBreakdown(UUID providerProfileId) {
        ProviderProfile profile = providerRepository.findById(providerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found"));
        RatingBreakdownProjection b = reviewRepository.ratingBreakdown(profile.getUser().getId());
        return new RatingBreakdownResponse(
                round(b.getService()), round(b.getPunctuality()), round(b.getValueScore()), b.getTotal());
    }

    private static double round(Double v) {
        return v == null ? 0.0 : Math.round(v * 10.0) / 10.0;
    }

    private BigDecimal enhancedRating(int stars, Optional<SentimentResult> sentiment) {
        BigDecimal star = BigDecimal.valueOf(stars);
        if (sentiment.isEmpty()) {
            return star.setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal textStar = BigDecimal.valueOf(sentiment.get().starRating());
        return star.multiply(starWeight)
                .add(textStar.multiply(textWeight))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Apply a review's contribution to the provider aggregate: {@code countDelta}
     * of +1 when a review is added/restored, -1 when it is hidden. Keeps the
     * denormalised {@code rating_sum}/{@code rating_count} and the Bayesian
     * {@code avg_rating} in step.
     */
    private void adjustProviderAggregate(UUID providerUserId, BigDecimal enhanced, int countDelta) {
        ProviderProfile profile = providerRepository.findByUserId(providerUserId).orElse(null);
        if (profile == null) {
            return;
        }
        int newCount = Math.max(0, profile.getRatingCount() + countDelta);
        BigDecimal current = profile.getRatingSum() == null ? BigDecimal.ZERO : profile.getRatingSum();
        BigDecimal newSum = countDelta >= 0 ? current.add(enhanced) : current.subtract(enhanced);
        if (newSum.signum() < 0) {
            newSum = BigDecimal.ZERO;
        }
        profile.setRatingCount(newCount);
        profile.setRatingSum(newSum);
        if (newCount == 0) {
            profile.setAvgRating(BigDecimal.ZERO);
        } else {
            BigDecimal rawAverage = newSum.divide(BigDecimal.valueOf(newCount), 10, RoundingMode.HALF_UP);
            profile.setAvgRating(bayesianCalculator.compute(newCount, rawAverage)); // Bayesian, not naive avg
        }
        providerRepository.save(profile);
    }

    private String reviewerName(UUID userId) {
        return userRepository.findById(userId).map(User::getFullName).orElse(null);
    }

    private Map<UUID, String> reviewerNames(List<Review> reviews) {
        Set<UUID> ids = reviews.stream().map(Review::getCustomerId).collect(Collectors.toSet());
        return userRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(User::getId, User::getFullName));
    }
}
