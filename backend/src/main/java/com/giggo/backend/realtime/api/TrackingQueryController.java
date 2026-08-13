package com.giggo.backend.realtime.api;

import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.realtime.api.dto.ProviderLocation;
import com.giggo.backend.realtime.service.LocationTrackingService;

import lombok.RequiredArgsConstructor;

/** Last-known provider location for a job — for initial render, late join, or when the socket is down. */
@RestController
@RequestMapping("/api/v1/tracking")
@RequiredArgsConstructor
public class TrackingQueryController {

    private final LocationTrackingService trackingService;

    @GetMapping("/{jobId}/location")
    public ApiResponse<ProviderLocation> lastKnown(@PathVariable UUID jobId) {
        return ApiResponse.ok(trackingService.lastKnown(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("No location for this job yet")));
    }
}
