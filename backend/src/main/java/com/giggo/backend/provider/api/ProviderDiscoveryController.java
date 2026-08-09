package com.giggo.backend.provider.api;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.provider.api.dto.ProviderCardResponse;
import com.giggo.backend.provider.api.dto.ProviderDetailResponse;
import com.giggo.backend.provider.service.ProviderDiscoveryService;

import lombok.RequiredArgsConstructor;

/** Customer-facing provider discovery endpoints (any authenticated user). */
@RestController
@RequestMapping("/api/v1/providers")
@RequiredArgsConstructor
public class ProviderDiscoveryController {

    private final ProviderDiscoveryService discoveryService;

    @GetMapping
    public ApiResponse<List<ProviderCardResponse>> search(
            @RequestParam(required = false) UUID categoryId,
            @RequestParam(required = false) UUID skillId,
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String q) {
        return ApiResponse.ok(discoveryService.search(categoryId, skillId, district, q));
    }

    @GetMapping("/{id}")
    public ApiResponse<ProviderDetailResponse> get(@PathVariable UUID id) {
        return ApiResponse.ok(discoveryService.getById(id));
    }
}
