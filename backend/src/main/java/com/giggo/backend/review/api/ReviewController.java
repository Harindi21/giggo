package com.giggo.backend.review.api;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.review.api.dto.CreateReviewRequest;
import com.giggo.backend.review.api.dto.RatingBreakdownResponse;
import com.giggo.backend.review.api.dto.ReviewResponse;
import com.giggo.backend.review.service.ReviewService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    /** Submit a review for a completed job (customer only, once per job). */
    @PostMapping("/bookings/{bookingId}/reviews")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<ReviewResponse> submit(
            @AuthenticationPrincipal User user,
            @PathVariable UUID bookingId,
            @Valid @RequestBody CreateReviewRequest req) {
        return ApiResponse.ok(reviewService.submit(user.getId(), bookingId, req));
    }

    /** Public reviews for a provider (by provider-profile id). */
    @GetMapping("/providers/{providerId}/reviews")
    public ApiResponse<List<ReviewResponse>> forProvider(@PathVariable UUID providerId) {
        return ApiResponse.ok(reviewService.listForProviderProfile(providerId));
    }

    /** Per-dimension rating averages for a provider (P6.6). */
    @GetMapping("/providers/{providerId}/rating-breakdown")
    public ApiResponse<RatingBreakdownResponse> ratingBreakdown(@PathVariable UUID providerId) {
        return ApiResponse.ok(reviewService.ratingBreakdown(providerId));
    }

    /** Report a review for moderation (any authenticated user) — P6.5. */
    @PostMapping("/reviews/{id}/report")
    public ApiResponse<Void> report(@PathVariable UUID id) {
        reviewService.report(id);
        return ApiResponse.ok(null);
    }
}
