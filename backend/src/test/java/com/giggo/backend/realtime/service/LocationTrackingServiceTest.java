package com.giggo.backend.realtime.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.realtime.api.dto.LocationUpdate;
import com.giggo.backend.realtime.api.dto.ProviderLocation;

@ExtendWith(MockitoExtension.class)
@DisplayName("LocationTrackingService")
class LocationTrackingServiceTest {

    @Mock
    private TrackingConsentService consentService;
    @Mock
    private SimpMessagingTemplate messaging;

    private LocationTrackingService service() {
        return new LocationTrackingService(consentService, messaging);
    }

    private final UUID jobId = UUID.randomUUID();
    private final UUID providerId = UUID.randomUUID();
    private final LocationUpdate valid = new LocationUpdate(6.9271, 79.8612, 45.0, 20.0, 5.0);

    @Test
    @DisplayName("consented ping is broadcast, cached and returned")
    void publishesWhenAllowed() {
        LocationTrackingService svc = service();
        when(consentService.canShareLocation(jobId, providerId)).thenReturn(true);

        ProviderLocation loc = svc.publish(jobId, providerId, valid);

        assertThat(loc.latitude()).isEqualTo(6.9271);
        assertThat(loc.jobId()).isEqualTo(jobId);
        assertThat(loc.at()).isNotNull();
        verify(messaging).convertAndSend(eq("/topic/jobs/" + jobId + "/location"), any(ProviderLocation.class));
        assertThat(svc.lastKnown(jobId)).contains(loc);
    }

    @Test
    @DisplayName("without consent: rejected, nothing broadcast or cached")
    void rejectedWhenNotAllowed() {
        LocationTrackingService svc = service();
        when(consentService.canShareLocation(jobId, providerId)).thenReturn(false);

        assertThatThrownBy(() -> svc.publish(jobId, providerId, valid))
                .isInstanceOf(ForbiddenOperationException.class);

        verify(messaging, never()).convertAndSend(any(String.class), any(Object.class));
        assertThat(svc.lastKnown(jobId)).isEmpty();
    }

    @Test
    @DisplayName("invalid coordinates are rejected before any consent check")
    void rejectsInvalidCoordinates() {
        LocationTrackingService svc = service();
        LocationUpdate bad = new LocationUpdate(200.0, 79.0, null, null, null);

        assertThatThrownBy(() -> svc.publish(jobId, providerId, bad))
                .isInstanceOf(IllegalArgumentException.class);

        verify(messaging, never()).convertAndSend(any(String.class), any(Object.class));
    }

    @Test
    @DisplayName("lastKnown is empty until a ping arrives")
    void lastKnownEmptyInitially() {
        assertThat(service().lastKnown(jobId)).isEmpty();
    }
}
