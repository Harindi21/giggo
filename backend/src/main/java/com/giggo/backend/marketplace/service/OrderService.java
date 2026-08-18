package com.giggo.backend.marketplace.service;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.marketplace.api.dto.PlaceOrderRequest;
import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.domain.ToolOrder;
import com.giggo.backend.marketplace.repository.ToolOrderRepository;
import com.giggo.backend.marketplace.repository.ToolRepository;
import com.giggo.backend.payment.gateway.CheckoutSession;
import com.giggo.backend.payment.gateway.PaymentGateway;

/**
 * Tool marketplace orders (P10.3). A tool purchase is a direct sale (not the
 * held-in-escrow flow used for services): place an order, pay, done. Checkout
 * reuses the same {@link PaymentGateway} adapter as booking payments.
 */
@Service
public class OrderService {

    private final ToolOrderRepository orderRepository;
    private final ToolRepository toolRepository;
    private final PaymentGateway gateway;

    public OrderService(
            ToolOrderRepository orderRepository,
            ToolRepository toolRepository,
            List<PaymentGateway> gateways,
            @Value("${giggo.payments.gateway:stub}") String gatewayName) {
        this.orderRepository = orderRepository;
        this.toolRepository = toolRepository;
        this.gateway = gateways.stream()
                .filter(g -> gatewayName.equalsIgnoreCase(g.name()))
                .findFirst()
                .orElse(gateways.get(0));
    }

    @Transactional
    public OrderResult place(UUID customerId, PlaceOrderRequest req) {
        Tool tool = toolRepository.findById(req.toolId())
                .orElseThrow(() -> new ResourceNotFoundException("Tool not found"));
        if (!tool.isAvailable()) {
            throw new IllegalArgumentException("This tool is not available");
        }
        BigDecimal unit = tool.getPrice();
        BigDecimal total = unit.multiply(BigDecimal.valueOf(req.quantity()));

        ToolOrder order = ToolOrder.builder()
                .customerId(customerId)
                .toolId(tool.getId())
                .toolName(tool.getName())
                .unitPrice(unit)
                .quantity(req.quantity())
                .totalPrice(total)
                .currency("LKR")
                .status(OrderStatus.PENDING)
                .gateway(gateway.name())
                .contactName(req.contactName())
                .contactPhone(req.contactPhone())
                .shippingAddress(req.shippingAddress())
                .build();

        CheckoutSession session = gateway.initiate(total, "LKR");
        order.setGateway(session.gateway());
        order.setGatewayRef(session.gatewayRef());
        return new OrderResult(orderRepository.save(order), session.checkoutUrl());
    }

    /** Gateway capture callback (stubbed): mark the order paid. */
    @Transactional
    public ToolOrder pay(UUID customerId, UUID orderId) {
        ToolOrder order = get(orderId);
        requireOwner(order, customerId);
        if (order.getStatus() == OrderStatus.PAID) {
            return order; // idempotent
        }
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException(
                    "Cannot pay for an order in state " + order.getStatus());
        }
        order.setStatus(OrderStatus.PAID);
        order.setPaidAt(OffsetDateTime.now());
        return orderRepository.save(order);
    }

    @Transactional
    public ToolOrder cancel(UUID customerId, UUID orderId) {
        ToolOrder order = get(orderId);
        requireOwner(order, customerId);
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Only a pending order can be cancelled");
        }
        order.setStatus(OrderStatus.CANCELLED);
        return orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public List<ToolOrder> listMine(UUID customerId) {
        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customerId);
    }

    @Transactional(readOnly = true)
    public ToolOrder getForCustomer(UUID customerId, UUID orderId) {
        ToolOrder order = get(orderId);
        requireOwner(order, customerId);
        return order;
    }

    private ToolOrder get(UUID id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
    }

    private void requireOwner(ToolOrder order, UUID userId) {
        if (!order.getCustomerId().equals(userId)) {
            throw new ForbiddenOperationException("This is not your order");
        }
    }

    /** An order plus the one-time checkout URL returned when it is placed. */
    public record OrderResult(ToolOrder order, String checkoutUrl) {}
}
