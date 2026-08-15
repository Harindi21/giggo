package com.giggo.backend.kyc.api;

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

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.kyc.api.dto.KycSubmissionResponse;
import com.giggo.backend.kyc.api.dto.ReviewKycRequest;
import com.giggo.backend.kyc.domain.KycStatus;
import com.giggo.backend.kyc.service.KycService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Admin KYC review queue (P2.2). */
@RestController
@RequestMapping("/api/v1/admin/kyc")
@RequiredArgsConstructor
public class AdminKycController {

    private final KycService kycService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<KycSubmissionResponse>> list(
            @RequestParam(defaultValue = "PENDING") KycStatus status) {
        return ApiResponse.ok(kycService.listByStatus(status).stream()
                .map(KycSubmissionResponse::from)
                .toList());
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<KycSubmissionResponse> approve(
            @AuthenticationPrincipal User admin, @PathVariable UUID id) {
        return ApiResponse.ok(KycSubmissionResponse.from(
                kycService.review(admin.getId(), id, true, null)));
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<KycSubmissionResponse> reject(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID id,
            @RequestBody(required = false) ReviewKycRequest body) {
        String note = body == null ? null : body.note();
        return ApiResponse.ok(KycSubmissionResponse.from(
                kycService.review(admin.getId(), id, false, note)));
    }
}
