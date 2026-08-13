package com.giggo.backend.realtime.api;

import java.security.Principal;
import java.util.Map;
import java.util.UUID;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.realtime.api.dto.LocationUpdate;
import com.giggo.backend.realtime.service.LocationTrackingService;

import lombok.RequiredArgsConstructor;

/**
 * Provider streams GPS to {@code /app/jobs/{jobId}/location}. The service checks
 * consent and, if permitted, broadcasts to {@code /topic/jobs/{jobId}/location}.
 * Errors are returned privately to the sender on {@code /user/queue/errors}.
 */
@Controller
@RequiredArgsConstructor
public class LocationSocketController {

    private final LocationTrackingService trackingService;

    @MessageMapping("/jobs/{jobId}/location")
    public void update(@DestinationVariable UUID jobId, LocationUpdate payload, Principal principal) {
        if (principal == null) {
            throw new ForbiddenOperationException("Not authenticated");
        }
        UUID providerUserId = UUID.fromString(principal.getName());
        trackingService.publish(jobId, providerUserId, payload);
    }

    @MessageExceptionHandler({ForbiddenOperationException.class, IllegalArgumentException.class})
    @SendToUser("/queue/errors")
    public Map<String, String> handleError(Exception ex) {
        return Map.of("error", ex.getMessage());
    }
}
