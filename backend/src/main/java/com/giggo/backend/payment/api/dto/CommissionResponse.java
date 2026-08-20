package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;
import java.util.UUID;

/** A category's effective commission rate (P11.8). */
public record CommissionResponse(
        UUID categoryId,
        String categoryName,
        BigDecimal rate,
        boolean usingDefault
) {}
