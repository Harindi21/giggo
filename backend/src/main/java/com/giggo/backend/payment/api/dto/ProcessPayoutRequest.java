package com.giggo.backend.payment.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Admin marks a payout paid, recording the bank-transfer reference. */
public record ProcessPayoutRequest(
        @NotBlank @Size(max = 160) String reference
) {}
