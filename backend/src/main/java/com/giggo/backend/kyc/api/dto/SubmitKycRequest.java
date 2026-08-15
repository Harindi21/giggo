package com.giggo.backend.kyc.api.dto;

import com.giggo.backend.kyc.domain.KycDocumentType;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SubmitKycRequest(
        @NotBlank @Size(max = 150) String fullName,
        @NotNull KycDocumentType documentType,
        @NotBlank @Size(max = 60) String documentNumber,
        @Size(max = 500) String documentImageUrl
) {}
