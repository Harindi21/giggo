package com.giggo.backend.payment.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Admin declines a payout, with a reason returned to the provider. */
public record RejectPayoutRequest(
        @NotBlank @Size(max = 500) String note
) {}
