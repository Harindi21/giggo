package com.giggo.backend.review.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
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

import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.review.domain.Review;
import com.giggo.backend.review.repository.ReviewRepository;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ReviewService moderation (P6.5)")
class ReviewModerationTest {

    @Mock ReviewRepository reviewRepository;
    @Mock BookingRepository bookingRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock UserRepository userRepository;
    @Mock SentimentClient sentimentClient;
    @Mock BookingService bookingService;
    @Mock BayesianRatingCalculator bayesianCalculator;

    private ReviewService service;

    private final UUID reviewId = UUID.randomUUID();
    private final UUID providerUserId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new ReviewService(reviewRepository, bookingRepository, providerRepository,
                userRepository, sentimentClient, bookingService, bayesianCalculator);
        lenient().when(reviewRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        lenient().when(bayesianCalculator.compute(anyInt(), any())).thenReturn(new BigDecimal("4.20"));
    }

    private Review review(boolean hidden) {
        return Review.builder()
                .id(reviewId).bookingId(UUID.randomUUID())
                .customerId(UUID.randomUUID()).providerId(providerUserId)
                .stars(5).enhancedRating(new BigDecimal("4.50")).hidden(hidden)
                .build();
    }

    private ProviderProfile profile(int count, String sum) {
        return ProviderProfile.builder()
                .id(UUID.randomUUID())
                .ratingCount(count).ratingSum(new BigDecimal(sum))
                .build();
    }

    @Test
    @DisplayName("report increments the report count")
    void reportIncrements() {
        when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review(false)));
        assertThat(service.report(reviewId).getReportCount()).isEqualTo(1);
    }

    @Test
    @DisplayName("hide removes the review's contribution from the provider aggregate")
    void hideRemovesContribution() {
        when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review(false)));
        ProviderProfile profile = profile(3, "13.50");
        when(providerRepository.findByUserId(providerUserId)).thenReturn(Optional.of(profile));

        Review out = service.hide(reviewId, "Spam");

        assertThat(out.isHidden()).isTrue();
        assertThat(out.getModerationReason()).isEqualTo("Spam");
        assertThat(profile.getRatingCount()).isEqualTo(2);
        assertThat(profile.getRatingSum()).isEqualByComparingTo("9.00");
    }

    @Test
    @DisplayName("hiding an already-hidden review is a no-op for the aggregate")
    void hideIsIdempotent() {
        when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review(true)));

        service.hide(reviewId, "again");

        verify(providerRepository, never()).save(any());
    }

    @Test
    @DisplayName("restore re-adds the contribution")
    void restoreReAdds() {
        when(reviewRepository.findById(reviewId)).thenReturn(Optional.of(review(true)));
        ProviderProfile profile = profile(2, "9.00");
        when(providerRepository.findByUserId(providerUserId)).thenReturn(Optional.of(profile));

        Review out = service.restore(reviewId);

        assertThat(out.isHidden()).isFalse();
        assertThat(profile.getRatingCount()).isEqualTo(3);
        assertThat(profile.getRatingSum()).isEqualByComparingTo("13.50");
    }
}
