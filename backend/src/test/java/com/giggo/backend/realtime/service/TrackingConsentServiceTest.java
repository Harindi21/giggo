package com.giggo.backend.realtime.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.realtime.api.dto.RequestConsentRequest;
import com.giggo.backend.realtime.api.dto.TrackingConsentResponse;
import com.giggo.backend.realtime.domain.ConsentStatus;
import com.giggo.backend.realtime.domain.TrackingConsent;
import com.giggo.backend.realtime.repository.TrackingConsentRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("TrackingConsentService")
class TrackingConsentServiceTest {

    @Mock
    private TrackingConsentRepository repository;

    private TrackingConsentService service;

    private final UUID jobId = UUID.randomUUID();
    private final UUID customerId = UUID.randomUUID();
    private final UUID providerId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new TrackingConsentService(repository);
        // save() echoes the entity back so we can assert on the mutated state.
        // lenient: some tests throw before ever reaching save().
        lenient().when(repository.save(any(TrackingConsent.class))).thenAnswer(inv -> inv.getArgument(0));
    }

    private TrackingConsent pending(UUID requestedBy) {
        return TrackingConsent.builder()
                .id(UUID.randomUUID()).jobId(jobId)
                .customerId(customerId).providerId(providerId)
                .requestedBy(requestedBy).status(ConsentStatus.PENDING)
                .build();
    }

    @Test
    @DisplayName("participant can request; consent starts PENDING")
    void requestCreatesPending() {
        when(repository.existsByJobIdAndStatusIn(any(), anyCollection())).thenReturn(false);
        TrackingConsentResponse r = service.request(customerId,
                new RequestConsentRequest(jobId, customerId, providerId));
        assertThat(r.status()).isEqualTo(ConsentStatus.PENDING);
        assertThat(r.requestedBy()).isEqualTo(customerId);
        assertThat(r.active()).isFalse();
    }

    @Test
    @DisplayName("non-participant cannot request")
    void nonParticipantCannotRequest() {
        assertThatThrownBy(() -> service.request(UUID.randomUUID(),
                new RequestConsentRequest(jobId, customerId, providerId)))
                .isInstanceOf(ForbiddenOperationException.class);
    }

    @Test
    @DisplayName("duplicate active consent is rejected")
    void duplicateRejected() {
        when(repository.existsByJobIdAndStatusIn(any(), anyCollection())).thenReturn(true);
        assertThatThrownBy(() -> service.request(customerId,
                new RequestConsentRequest(jobId, customerId, providerId)))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    @DisplayName("the other party grants -> GRANTED and active with an expiry window")
    void counterpartyGrants() {
        UUID id = UUID.randomUUID();
        TrackingConsent c = pending(customerId); // customer requested
        c.setId(id);
        when(repository.findById(id)).thenReturn(Optional.of(c));

        TrackingConsentResponse r = service.grant(providerId, id, 30); // provider grants

        assertThat(r.status()).isEqualTo(ConsentStatus.GRANTED);
        assertThat(r.active()).isTrue();
        assertThat(r.expiresAt()).isAfter(OffsetDateTime.now());
    }

    @Test
    @DisplayName("requester cannot grant their own request")
    void requesterCannotGrantOwn() {
        UUID id = UUID.randomUUID();
        TrackingConsent c = pending(customerId);
        c.setId(id);
        when(repository.findById(id)).thenReturn(Optional.of(c));
        assertThatThrownBy(() -> service.grant(customerId, id, 30))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("either participant can revoke an active consent")
    void participantRevokes() {
        UUID id = UUID.randomUUID();
        TrackingConsent c = pending(customerId);
        c.setId(id);
        c.setStatus(ConsentStatus.GRANTED);
        c.setExpiresAt(OffsetDateTime.now().plusMinutes(30));
        when(repository.findById(id)).thenReturn(Optional.of(c));

        TrackingConsentResponse r = service.revoke(customerId, id);
        assertThat(r.status()).isEqualTo(ConsentStatus.REVOKED);
    }

    @Test
    @DisplayName("isSharingAllowed: true only for a GRANTED, unexpired consent")
    void sharingAllowed() {
        TrackingConsent active = pending(customerId);
        active.setStatus(ConsentStatus.GRANTED);
        active.setExpiresAt(OffsetDateTime.now().plusMinutes(5));
        when(repository.findByJobIdAndStatus(jobId, ConsentStatus.GRANTED)).thenReturn(Optional.of(active));
        assertThat(service.isSharingAllowed(jobId)).isTrue();

        active.setExpiresAt(OffsetDateTime.now().minusMinutes(1)); // expired
        assertThat(service.isSharingAllowed(jobId)).isFalse();
    }
}
