package com.giggo.backend.review.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.review.api.dto.AdminReviewResponse;
import com.giggo.backend.review.api.dto.HideReviewRequest;
import com.giggo.backend.review.service.ReviewService;

import lombok.RequiredArgsConstructor;

/** Admin review moderation (P6.5). */
@RestController
@RequestMapping("/api/v1/admin/reviews")
@RequiredArgsConstructor
public class AdminReviewController {

    private final ReviewService reviewService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<AdminReviewResponse>> list(
            @RequestParam(defaultValue = "false") boolean reportedOnly) {
        return ApiResponse.ok(reviewService.adminList(reportedOnly));
    }

    @PostMapping("/{id}/hide")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminReviewResponse> hide(
            @PathVariable UUID id,
            @RequestBody(required = false) HideReviewRequest body) {
        String reason = body == null ? null : body.reason();
        return ApiResponse.ok(AdminReviewResponse.from(reviewService.hide(id, reason), null));
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminReviewResponse> restore(@PathVariable UUID id) {
        return ApiResponse.ok(AdminReviewResponse.from(reviewService.restore(id), null));
    }
}
