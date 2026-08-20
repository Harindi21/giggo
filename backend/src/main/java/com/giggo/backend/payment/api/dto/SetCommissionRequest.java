package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

/** Admin sets a category's commission rate (a fraction, 0..1). */
public record SetCommissionRequest(
        @NotNull @DecimalMin("0.0") @DecimalMax("1.0") BigDecimal rate
) {}
