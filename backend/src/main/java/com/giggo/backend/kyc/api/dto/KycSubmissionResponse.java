package com.giggo.backend.kyc.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.kyc.domain.KycDocumentType;
import com.giggo.backend.kyc.domain.KycStatus;
import com.giggo.backend.kyc.domain.KycSubmission;

public record KycSubmissionResponse(
        UUID id,
        UUID providerUserId,
        String fullName,
        KycDocumentType documentType,
        String documentNumber,
        String documentImageUrl,
        KycStatus status,
        String reviewNote,
        OffsetDateTime submittedAt,
        OffsetDateTime reviewedAt
) {
    public static KycSubmissionResponse from(KycSubmission s) {
        return new KycSubmissionResponse(
                s.getId(), s.getProviderUserId(), s.getFullName(), s.getDocumentType(),
                s.getDocumentNumber(), s.getDocumentImageUrl(), s.getStatus(),
                s.getReviewNote(), s.getSubmittedAt(), s.getReviewedAt());
    }
}
