package com.giggo.backend.review.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.service.AuditService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.review.api.dto.AdminReviewResponse;
import com.giggo.backend.review.api.dto.HideReviewRequest;
import com.giggo.backend.review.service.ReviewService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Admin review moderation (P6.5). */
@RestController
@RequestMapping("/api/v1/admin/reviews")
@RequiredArgsConstructor
public class AdminReviewController {

    private final ReviewService reviewService;
    private final AuditService auditService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<AdminReviewResponse>> list(
            @RequestParam(defaultValue = "false") boolean reportedOnly) {
        return ApiResponse.ok(reviewService.adminList(reportedOnly));
    }

    @PostMapping("/{id}/hide")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminReviewResponse> hide(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID id,
            @RequestBody(required = false) HideReviewRequest body) {
        String reason = body == null ? null : body.reason();
        AdminReviewResponse result = AdminReviewResponse.from(reviewService.hide(id, reason), null);
        auditService.record(admin.getId(), "REVIEW_HIDDEN", "REVIEW", id, reason);
        return ApiResponse.ok(result);
    }

    @PostMapping("/{id}/restore")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminReviewResponse> restore(
            @AuthenticationPrincipal User admin, @PathVariable UUID id) {
        AdminReviewResponse result = AdminReviewResponse.from(reviewService.restore(id), null);
        auditService.record(admin.getId(), "REVIEW_RESTORED", "REVIEW", id, null);
        return ApiResponse.ok(result);
    }
}
