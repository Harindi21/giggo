package com.giggo.backend.marketplace.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.domain.ToolOrder;

public record OrderResponse(
        UUID id,
        UUID toolId,
        String toolName,
        BigDecimal unitPrice,
        int quantity,
        BigDecimal totalPrice,
        String currency,
        OrderStatus status,
        String gatewayRef,
        String checkoutUrl,   // only present right after placing
        String contactName,
        String contactPhone,
        String shippingAddress,
        OffsetDateTime paidAt,
        OffsetDateTime createdAt
) {
    public static OrderResponse from(ToolOrder o) {
        return of(o, null);
    }

    public static OrderResponse of(ToolOrder o, String checkoutUrl) {
        return new OrderResponse(
                o.getId(), o.getToolId(), o.getToolName(), o.getUnitPrice(), o.getQuantity(),
                o.getTotalPrice(), o.getCurrency(), o.getStatus(), o.getGatewayRef(), checkoutUrl,
                o.getContactName(), o.getContactPhone(), o.getShippingAddress(),
                o.getPaidAt(), o.getCreatedAt());
    }
}
