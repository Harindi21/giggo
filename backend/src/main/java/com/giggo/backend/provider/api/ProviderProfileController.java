package com.giggo.backend.provider.api;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.provider.api.dto.ProviderProfileResponse;
import com.giggo.backend.provider.api.dto.UpdateProviderProfileRequest;
import com.giggo.backend.provider.service.ProviderProfileService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/provider/profile")
@RequiredArgsConstructor
public class ProviderProfileController {

    private final ProviderProfileService profileService;

    @GetMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<ProviderProfileResponse> myProfile(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(profileService.getOrCreateMyProfile(user.getId()));
    }

    @PutMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<ProviderProfileResponse> updateProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateProviderProfileRequest req) {
        return ApiResponse.ok(profileService.updateMyProfile(user.getId(), req));
    }
}