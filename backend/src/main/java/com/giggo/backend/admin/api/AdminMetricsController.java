package com.giggo.backend.admin.api;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.api.dto.AdminMetricsResponse;
import com.giggo.backend.admin.service.AdminMetricsService;
import com.giggo.backend.common.dto.ApiResponse;

import lombok.RequiredArgsConstructor;

/** Admin analytics dashboard metrics (P11.1, P11.7). */
@RestController
@RequestMapping("/api/v1/admin/metrics")
@RequiredArgsConstructor
public class AdminMetricsController {

    private final AdminMetricsService adminMetricsService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<AdminMetricsResponse> metrics() {
        return ApiResponse.ok(adminMetricsService.metrics());
    }
}
