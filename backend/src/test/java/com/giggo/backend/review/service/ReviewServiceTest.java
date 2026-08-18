package com.giggo.backend.review.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.lenient;
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
import org.springframework.test.util.ReflectionTestUtils;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.review.api.dto.CreateReviewRequest;
import com.giggo.backend.review.api.dto.ReviewResponse;
import com.giggo.backend.review.domain.Review;
import com.giggo.backend.review.repository.ReviewRepository;
import com.giggo.backend.review.service.SentimentClient.SentimentResult;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("ReviewService")
class ReviewServiceTest {

    @Mock ReviewRepository reviewRepository;
    @Mock BookingRepository bookingRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock UserRepository userRepository;
    @Mock SentimentClient sentimentClient;
    @Mock BookingService bookingService;
    @Mock BayesianRatingCalculator bayesianCalculator;

    private ReviewService service;

    private final UUID customerId = UUID.randomUUID();
    private final UUID providerUserId = UUID.randomUUID();
    private final UUID bookingId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new ReviewService(reviewRepository, bookingRepository, providerRepository,
                userRepository, sentimentClient, bookingService, bayesianCalculator);
        ReflectionTestUtils.setField(service, "starWeight", new BigDecimal("0.6"));
        ReflectionTestUtils.setField(service, "textWeight", new BigDecimal("0.4"));
        lenient().when(reviewRepository.save(any(Review.class))).thenAnswer(inv -> inv.getArgument(0));
    }

    private Booking completed() {
        return Booking.builder().id(bookingId).customerId(customerId).providerId(providerUserId)
                .skillId(UUID.randomUUID()).status(JobStatus.COMPLETED).build();
    }

    @Test
    @DisplayName("stores sentiment, computes enhanced rating and nudges the provider average")
    void submitsWithSentiment() {
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(completed()));
        when(reviewRepository.existsByBookingId(bookingId)).thenReturn(false);
        when(sentimentClient.analyze(any())).thenReturn(Optional.of(
                new SentimentResult("positive", 0.9, 5, 0.95, "satisfaction", "en")));
        ProviderProfile profile = ProviderProfile.builder()
                .avgRating(new BigDecimal("4.00")).ratingCount(10).ratingSum(new BigDecimal("40.00")).build();
        when(providerRepository.findByUserId(providerUserId)).thenReturn(Optional.of(profile));
        when(userRepository.findById(customerId)).thenReturn(Optional.of(
                User.builder().id(customerId).fullName("Ann").build()));
        when(bayesianCalculator.compute(anyInt(), any())).thenReturn(new BigDecimal("4.05"));

        ReviewResponse r = service.submit(customerId, bookingId, new CreateReviewRequest(4, "great, fast and tidy"));

        assertThat(r.sentimentLabel()).isEqualTo("positive");
        assertThat(r.enhancedRating()).isEqualByComparingTo("4.40"); // 4*0.6 + 5*0.4
        assertThat(r.reviewerName()).isEqualTo("Ann");
        verify(bookingService).markRated(bookingId);
        // count + raw sum advance; avg comes from the Bayesian calculator
        assertThat(profile.getRatingCount()).isEqualTo(11);
        assertThat(profile.getRatingSum()).isEqualByComparingTo("44.40"); // 40.00 + 4.40
        assertThat(profile.getAvgRating()).isEqualByComparingTo("4.05");
    }

    @Test
    @DisplayName("falls back gracefully when the NLP service is unavailable")
    void submitsWithoutSentiment() {
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(completed()));
        when(reviewRepository.existsByBookingId(bookingId)).thenReturn(false);
        when(sentimentClient.analyze(any())).thenReturn(Optional.empty());
        when(providerRepository.findByUserId(providerUserId)).thenReturn(Optional.empty());
        when(userRepository.findById(customerId)).thenReturn(Optional.empty());

        ReviewResponse r = service.submit(customerId, bookingId, new CreateReviewRequest(5, "solid work"));

        assertThat(r.sentimentLabel()).isNull();
        assertThat(r.enhancedRating()).isEqualByComparingTo("5.00"); // just the stars
        verify(bookingService).markRated(bookingId);
    }

    @Test
    @DisplayName("only a completed job can be reviewed")
    void rejectsNonCompleted() {
        Booking b = completed();
        b.setStatus(JobStatus.STARTED);
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(b));
        assertThatThrownBy(() -> service.submit(customerId, bookingId, new CreateReviewRequest(5, "x")))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("only the job's customer can review it")
    void rejectsNonCustomer() {
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(completed()));
        assertThatThrownBy(() -> service.submit(UUID.randomUUID(), bookingId, new CreateReviewRequest(5, "x")))
                .isInstanceOf(ForbiddenOperationException.class);
    }

    @Test
    @DisplayName("a job can only be reviewed once")
    void rejectsDuplicate() {
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(completed()));
        when(reviewRepository.existsByBookingId(bookingId)).thenReturn(true);
        assertThatThrownBy(() -> service.submit(customerId, bookingId, new CreateReviewRequest(5, "x")))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    @DisplayName("rejects the same review text copy-pasted across jobs (P6.4)")
    void rejectsDuplicateText() {
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(completed()));
        when(reviewRepository.existsByBookingId(bookingId)).thenReturn(false);
        when(reviewRepository.existsByCustomerIdAndBody(customerId, "great, fast and tidy")).thenReturn(true);
        assertThatThrownBy(() -> service.submit(
                customerId, bookingId, new CreateReviewRequest(5, "great, fast and tidy")))
                .isInstanceOf(DuplicateResourceException.class);
    }
}
