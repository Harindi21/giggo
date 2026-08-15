package com.giggo.backend.recommendation.api;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.provider.api.dto.ProviderCardResponse;
import com.giggo.backend.recommendation.service.RecommendationService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Personalised "recommended for you" providers for the signed-in customer (P3.4). */
@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @GetMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<List<ProviderCardResponse>> recommendations(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng) {
        int bounded = Math.min(Math.max(limit, 1), 50);
        return ApiResponse.ok(recommendationService.recommendFor(user.getId(), bounded, lat, lng));
    }
}
