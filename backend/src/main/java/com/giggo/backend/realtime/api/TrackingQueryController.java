package com.giggo.backend.realtime.api;

import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.realtime.api.dto.EtaResponse;
import com.giggo.backend.realtime.api.dto.ProviderLocation;
import com.giggo.backend.realtime.service.EtaService;
import com.giggo.backend.realtime.service.LocationTrackingService;

import lombok.RequiredArgsConstructor;

/** Read-side tracking: last-known location and ETA to a destination. */
@RestController
@RequestMapping("/api/v1/tracking")
@RequiredArgsConstructor
public class TrackingQueryController {

    private final LocationTrackingService trackingService;
    private final EtaService etaService;

    @GetMapping("/{jobId}/location")
    public ApiResponse<ProviderLocation> lastKnown(@PathVariable UUID jobId) {
        return ApiResponse.ok(trackingService.lastKnown(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("No location for this job yet")));
    }

    @GetMapping("/{jobId}/eta")
    public ApiResponse<EtaResponse> eta(
            @PathVariable UUID jobId,
            @RequestParam double destLat,
            @RequestParam double destLng) {
        return ApiResponse.ok(etaService.forJob(jobId, destLat, destLng));
    }
}
