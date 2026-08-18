package com.giggo.backend.marketplace.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A customer's purchase of a tool (P10.3). Price is snapshotted at order time. */
@Entity
@Table(name = "tool_orders")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ToolOrder {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "tool_id", nullable = false)
    private UUID toolId;

    @Column(name = "tool_name", nullable = false, length = 200)
    private String toolName;

    @Column(name = "unit_price", nullable = false)
    private BigDecimal unitPrice;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    @Column(name = "total_price", nullable = false)
    private BigDecimal totalPrice;

    @Column(name = "currency", nullable = false, length = 3)
    @Builder.Default
    private String currency = "LKR";

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING;

    @Column(name = "gateway", nullable = false, length = 30)
    private String gateway;

    @Column(name = "gateway_ref", length = 120)
    private String gatewayRef;

    @Column(name = "contact_name", length = 120)
    private String contactName;

    @Column(name = "contact_phone", length = 30)
    private String contactPhone;

    @Column(name = "shipping_address", length = 400)
    private String shippingAddress;

    @Column(name = "paid_at")
    private OffsetDateTime paidAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void onCreate() {
        OffsetDateTime now = OffsetDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
