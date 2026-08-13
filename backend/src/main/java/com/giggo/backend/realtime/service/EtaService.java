package com.giggo.backend.realtime.service;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.realtime.api.dto.EtaResponse;
import com.giggo.backend.realtime.api.dto.ProviderLocation;
import com.giggo.backend.realtime.service.EtaCalculator.EtaResult;

import lombok.RequiredArgsConstructor;

/** ETA for a job, using the provider's most recent broadcast position (P5.4). */
@Service
@RequiredArgsConstructor
public class EtaService {

    private final LocationTrackingService trackingService;
    private final EtaCalculator etaCalculator;

    public EtaResponse forJob(UUID jobId, double destLat, double destLng) {
        ProviderLocation loc = trackingService.lastKnown(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("No provider location yet for this job"));
        EtaResult result = etaCalculator.estimate(
                loc.latitude(), loc.longitude(), destLat, destLng, loc.speedKmh());
        return new EtaResponse(
                jobId,
                result.distanceKm(),
                result.etaMinutes(),
                result.speedKmhUsed(),
                loc.latitude(),
                loc.longitude(),
                loc.at());
    }
}
