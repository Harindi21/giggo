package com.giggo.backend.realtime.api;

import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.realtime.api.dto.GrantConsentRequest;
import com.giggo.backend.realtime.api.dto.RequestConsentRequest;
import com.giggo.backend.realtime.api.dto.TrackingConsentResponse;
import com.giggo.backend.realtime.service.TrackingConsentService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Opt-in consent flow for live location sharing during a job (P5.2). */
@RestController
@RequestMapping("/api/v1/tracking/consent")
@RequiredArgsConstructor
public class TrackingConsentController {

    private final TrackingConsentService service;

    @PostMapping
    public ApiResponse<TrackingConsentResponse> request(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody RequestConsentRequest req) {
        return ApiResponse.ok(service.request(user.getId(), req));
    }

    @PostMapping("/{id}/grant")
    public ApiResponse<TrackingConsentResponse> grant(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @Valid @RequestBody(required = false) GrantConsentRequest req) {
        Integer minutes = (req == null) ? null : req.durationMinutes();
        return ApiResponse.ok(service.grant(user.getId(), id, minutes));
    }

    @PostMapping("/{id}/decline")
    public ApiResponse<TrackingConsentResponse> decline(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(service.decline(user.getId(), id));
    }

    @PostMapping("/{id}/revoke")
    public ApiResponse<TrackingConsentResponse> revoke(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(service.revoke(user.getId(), id));
    }

    @GetMapping
    public ApiResponse<TrackingConsentResponse> forJob(@RequestParam UUID jobId) {
        return ApiResponse.ok(service.forJob(jobId));
    }
}
