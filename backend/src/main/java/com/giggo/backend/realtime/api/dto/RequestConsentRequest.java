package com.giggo.backend.realtime.api.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;

/** Start a tracking-consent request for a job between a customer and a provider. */
public record RequestConsentRequest(
        @NotNull UUID jobId,
        @NotNull UUID customerId,
        @NotNull UUID providerId
) {}
