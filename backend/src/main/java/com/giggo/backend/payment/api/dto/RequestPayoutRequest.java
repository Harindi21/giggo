package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMin;

/** Provider withdrawal request. A null/blank amount withdraws the full available balance. */
public record RequestPayoutRequest(
        @DecimalMin("0.0") BigDecimal amount
) {}
