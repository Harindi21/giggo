package com.giggo.backend.provider.api;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.provider.api.dto.SetAvailabilityRequest;
import com.giggo.backend.provider.api.dto.WorkingHourResponse;
import com.giggo.backend.provider.service.AvailabilityService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Provider weekly working hours (P2.10). */
@RestController
@RequestMapping("/api/v1/provider/availability")
@RequiredArgsConstructor
public class AvailabilityController {

    private final AvailabilityService availabilityService;

    @GetMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<List<WorkingHourResponse>> get(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(availabilityService.getWorkingHours(user.getId()).stream()
                .map(WorkingHourResponse::from)
                .toList());
    }

    @PutMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<List<WorkingHourResponse>> set(
            @AuthenticationPrincipal User user, @Valid @RequestBody SetAvailabilityRequest req) {
        return ApiResponse.ok(availabilityService.setWorkingHours(user.getId(), req.days()).stream()
                .map(WorkingHourResponse::from)
                .toList());
    }
}
