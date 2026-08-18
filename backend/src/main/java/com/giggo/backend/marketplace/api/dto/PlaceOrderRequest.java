package com.giggo.backend.marketplace.api.dto;

import java.util.UUID;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record PlaceOrderRequest(
        @NotNull UUID toolId,
        @Min(1) @Max(99) int quantity,
        @Size(max = 120) String contactName,
        @Size(max = 30) String contactPhone,
        @Size(max = 400) String shippingAddress
) {}
