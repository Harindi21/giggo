package com.giggo.backend.forecast.api;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.forecast.api.dto.CategoryDemandResponse;
import com.giggo.backend.forecast.service.DemandService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Provider demand insights (AI #4). */
@RestController
@RequestMapping("/api/v1/provider/demand")
@RequiredArgsConstructor
public class DemandController {

    private final DemandService demandService;

    @GetMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<List<CategoryDemandResponse>> myDemand(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(demandService.demandForProvider(user.getId()));
    }
}
