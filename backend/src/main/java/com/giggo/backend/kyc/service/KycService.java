package com.giggo.backend.kyc.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.kyc.api.dto.SubmitKycRequest;
import com.giggo.backend.kyc.domain.KycStatus;
import com.giggo.backend.kyc.domain.KycSubmission;
import com.giggo.backend.kyc.repository.KycSubmissionRepository;
import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

import lombok.RequiredArgsConstructor;

/**
 * Provider KYC verification (P2.2). Providers submit an ID document; an admin
 * approves or rejects. Approval flips the provider's {@code verified} flag (the
 * badge shown across discovery) and the provider is notified either way.
 */
@Service
@RequiredArgsConstructor
public class KycService {

    private final KycSubmissionRepository kycRepository;
    private final ProviderProfileRepository providerRepository;
    private final NotificationService notificationService;

    /** Provider submits (or re-submits) their KYC details. */
    @Transactional
    public KycSubmission submit(UUID providerUserId, SubmitKycRequest req) {
        KycSubmission submission = kycRepository.findByProviderUserId(providerUserId)
                .orElseGet(() -> KycSubmission.builder().providerUserId(providerUserId).build());
        if (submission.getStatus() == KycStatus.APPROVED) {
            throw new IllegalArgumentException("Your account is already verified");
        }
        submission.setFullName(req.fullName());
        submission.setDocumentType(req.documentType());
        submission.setDocumentNumber(req.documentNumber());
        submission.setDocumentImageUrl(req.documentImageUrl());
        submission.setStatus(KycStatus.PENDING);
        submission.setReviewedBy(null);
        submission.setReviewNote(null);
        submission.setReviewedAt(null);
        submission.setSubmittedAt(OffsetDateTime.now());
        return kycRepository.save(submission);
    }

    @Transactional(readOnly = true)
    public KycSubmission getMine(UUID providerUserId) {
        return kycRepository.findByProviderUserId(providerUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No KYC submission yet"));
    }

    @Transactional(readOnly = true)
    public List<KycSubmission> listByStatus(KycStatus status) {
        return kycRepository.findByStatusOrderBySubmittedAtAsc(status);
    }

    /** Admin approves or rejects a pending submission. */
    @Transactional
    public KycSubmission review(UUID adminId, UUID submissionId, boolean approve, String note) {
        KycSubmission submission = kycRepository.findById(submissionId)
                .orElseThrow(() -> new ResourceNotFoundException("KYC submission not found"));
        if (submission.getStatus() != KycStatus.PENDING) {
            throw new IllegalArgumentException("This submission has already been reviewed");
        }
        submission.setStatus(approve ? KycStatus.APPROVED : KycStatus.REJECTED);
        submission.setReviewedBy(adminId);
        submission.setReviewNote(note);
        submission.setReviewedAt(OffsetDateTime.now());
        KycSubmission saved = kycRepository.save(submission);

        if (approve) {
            providerRepository.findByUserId(submission.getProviderUserId())
                    .ifPresent(this::markVerified);
            notificationService.notify(submission.getProviderUserId(), "KYC_APPROVED",
                    "You're verified", "Your identity was verified — the verified badge is now on your profile.", null);
        } else {
            notificationService.notify(submission.getProviderUserId(), "KYC_REJECTED",
                    "Verification needs attention",
                    note == null || note.isBlank()
                            ? "Your KYC submission was not approved. Please re-submit."
                            : "Your KYC submission was not approved: " + note,
                    null);
        }
        return saved;
    }

    private void markVerified(ProviderProfile profile) {
        profile.setVerified(true);
        providerRepository.save(profile);
    }
}
