package com.giggo.backend.kyc.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
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

import com.giggo.backend.kyc.api.dto.SubmitKycRequest;
import com.giggo.backend.kyc.domain.KycDocumentType;
import com.giggo.backend.kyc.domain.KycStatus;
import com.giggo.backend.kyc.domain.KycSubmission;
import com.giggo.backend.kyc.repository.KycSubmissionRepository;
import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("KycService")
class KycServiceTest {

    @Mock KycSubmissionRepository kycRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock NotificationService notificationService;

    private KycService service;

    private final UUID providerUserId = UUID.randomUUID();
    private final UUID adminId = UUID.randomUUID();
    private final UUID submissionId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new KycService(kycRepository, providerRepository, notificationService);
        lenient().when(kycRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private SubmitKycRequest request() {
        return new SubmitKycRequest("Nimal Perera", KycDocumentType.NIC, "199012345678", null);
    }

    private KycSubmission pending() {
        return KycSubmission.builder()
                .id(submissionId)
                .providerUserId(providerUserId)
                .fullName("Nimal Perera")
                .documentType(KycDocumentType.NIC)
                .documentNumber("199012345678")
                .status(KycStatus.PENDING)
                .submittedAt(OffsetDateTime.now())
                .build();
    }

    @Test
    @DisplayName("submit creates a pending submission")
    void submitCreatesPending() {
        when(kycRepository.findByProviderUserId(providerUserId)).thenReturn(Optional.empty());

        KycSubmission out = service.submit(providerUserId, request());

        assertThat(out.getStatus()).isEqualTo(KycStatus.PENDING);
        assertThat(out.getProviderUserId()).isEqualTo(providerUserId);
        assertThat(out.getDocumentNumber()).isEqualTo("199012345678");
    }

    @Test
    @DisplayName("submit is rejected when already verified")
    void submitRejectedWhenApproved() {
        KycSubmission approved = pending();
        approved.setStatus(KycStatus.APPROVED);
        when(kycRepository.findByProviderUserId(providerUserId)).thenReturn(Optional.of(approved));

        assertThatThrownBy(() -> service.submit(providerUserId, request()))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("approve verifies the provider and notifies them")
    void approveVerifiesProvider() {
        when(kycRepository.findById(submissionId)).thenReturn(Optional.of(pending()));
        ProviderProfile profile = ProviderProfile.builder().id(UUID.randomUUID()).verified(false).build();
        when(providerRepository.findByUserId(providerUserId)).thenReturn(Optional.of(profile));

        KycSubmission out = service.review(adminId, submissionId, true, null);

        assertThat(out.getStatus()).isEqualTo(KycStatus.APPROVED);
        assertThat(profile.isVerified()).isTrue();
        verify(notificationService).notify(eq(providerUserId), eq("KYC_APPROVED"), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("reject records the note and does not verify")
    void rejectDoesNotVerify() {
        when(kycRepository.findById(submissionId)).thenReturn(Optional.of(pending()));

        KycSubmission out = service.review(adminId, submissionId, false, "Document unreadable");

        assertThat(out.getStatus()).isEqualTo(KycStatus.REJECTED);
        assertThat(out.getReviewNote()).isEqualTo("Document unreadable");
        verify(providerRepository, never()).save(any());
        verify(notificationService).notify(eq(providerUserId), eq("KYC_REJECTED"), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("reviewing an already-reviewed submission fails")
    void reviewAlreadyReviewed() {
        KycSubmission approved = pending();
        approved.setStatus(KycStatus.APPROVED);
        when(kycRepository.findById(submissionId)).thenReturn(Optional.of(approved));

        assertThatThrownBy(() -> service.review(adminId, submissionId, true, null))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
