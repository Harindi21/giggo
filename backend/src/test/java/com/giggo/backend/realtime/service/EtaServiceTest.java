package com.giggo.backend.realtime.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.realtime.api.dto.EtaResponse;
import com.giggo.backend.realtime.api.dto.ProviderLocation;
import com.giggo.backend.realtime.service.EtaCalculator.EtaResult;

@ExtendWith(MockitoExtension.class)
@DisplayName("EtaService")
class EtaServiceTest {

    @Mock
    private LocationTrackingService trackingService;
    @Mock
    private EtaCalculator etaCalculator;

    private final UUID jobId = UUID.randomUUID();

    @Test
    @DisplayName("estimates from the provider's last-known position")
    void estimatesFromLastKnown() {
        EtaService service = new EtaService(trackingService, etaCalculator);
        ProviderLocation loc = new ProviderLocation(jobId, 6.90, 79.90, null, 30.0, null, OffsetDateTime.now());
        when(trackingService.lastKnown(jobId)).thenReturn(Optional.of(loc));
        when(etaCalculator.estimate(anyDouble(), anyDouble(), anyDouble(), anyDouble(), any(Double.class)))
                .thenReturn(new EtaResult(5.0, 12, 30.0));

        EtaResponse r = service.forJob(jobId, 6.85, 79.86);

        assertThat(r.distanceKm()).isEqualTo(5.0);
        assertThat(r.etaMinutes()).isEqualTo(12);
        assertThat(r.providerLatitude()).isEqualTo(6.90);
        assertThat(r.basedOn()).isEqualTo(loc.at());
    }

    @Test
    @DisplayName("throws when there is no location yet")
    void throwsWhenNoLocation() {
        EtaService service = new EtaService(trackingService, etaCalculator);
        when(trackingService.lastKnown(jobId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.forJob(jobId, 6.85, 79.86))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
