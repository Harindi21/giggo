package com.giggo.backend.kyc.api;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.kyc.api.dto.KycSubmissionResponse;
import com.giggo.backend.kyc.api.dto.SubmitKycRequest;
import com.giggo.backend.kyc.service.KycService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Provider-facing KYC submission (P2.2). */
@RestController
@RequestMapping("/api/v1/kyc")
@RequiredArgsConstructor
public class KycController {

    private final KycService kycService;

    @PostMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<KycSubmissionResponse> submit(
            @AuthenticationPrincipal User user, @Valid @RequestBody SubmitKycRequest req) {
        return ApiResponse.ok(KycSubmissionResponse.from(kycService.submit(user.getId(), req)));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<KycSubmissionResponse> mine(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(KycSubmissionResponse.from(kycService.getMine(user.getId())));
    }
}
