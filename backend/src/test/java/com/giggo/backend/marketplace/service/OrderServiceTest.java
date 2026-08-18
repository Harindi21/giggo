package com.giggo.backend.marketplace.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.marketplace.api.dto.PlaceOrderRequest;
import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.domain.Tool;
import com.giggo.backend.marketplace.domain.ToolOrder;
import com.giggo.backend.marketplace.repository.ToolOrderRepository;
import com.giggo.backend.marketplace.repository.ToolRepository;
import com.giggo.backend.payment.gateway.StubPaymentGateway;

@ExtendWith(MockitoExtension.class)
@DisplayName("OrderService")
class OrderServiceTest {

    @Mock ToolOrderRepository orderRepository;
    @Mock ToolRepository toolRepository;

    private OrderService service;

    private final UUID customerId = UUID.randomUUID();
    private final UUID toolId = UUID.randomUUID();
    private final UUID orderId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new OrderService(
                orderRepository, toolRepository,
                List.of(new StubPaymentGateway("https://sandbox.local/checkout")), "stub");
        lenient().when(orderRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private Tool tool(boolean available) {
        return Tool.builder()
                .id(toolId).slug("drill").name("Cordless Drill")
                .category("Power Tools").description("d")
                .price(new BigDecimal("12500")).available(available)
                .build();
    }

    private ToolOrder order(OrderStatus status) {
        return ToolOrder.builder()
                .id(orderId).customerId(customerId).toolId(toolId)
                .toolName("Cordless Drill").unitPrice(new BigDecimal("12500"))
                .quantity(1).totalPrice(new BigDecimal("12500"))
                .status(status).gateway("stub")
                .build();
    }

    @Test
    @DisplayName("place snapshots price, computes the total and returns a checkout")
    void placeComputesTotal() {
        when(toolRepository.findById(toolId)).thenReturn(Optional.of(tool(true)));
        var req = new PlaceOrderRequest(toolId, 2, "Ann", "0771234567", "No. 9");

        OrderService.OrderResult result = service.place(customerId, req);

        assertThat(result.order().getStatus()).isEqualTo(OrderStatus.PENDING);
        assertThat(result.order().getUnitPrice()).isEqualByComparingTo("12500");
        assertThat(result.order().getQuantity()).isEqualTo(2);
        assertThat(result.order().getTotalPrice()).isEqualByComparingTo("25000");
        assertThat(result.order().getGatewayRef()).isNotBlank();
        assertThat(result.checkoutUrl()).isNotNull();
    }

    @Test
    @DisplayName("cannot order an unavailable tool")
    void placeRejectsUnavailable() {
        when(toolRepository.findById(toolId)).thenReturn(Optional.of(tool(false)));

        assertThatThrownBy(() -> service.place(customerId, new PlaceOrderRequest(toolId, 1, null, null, null)))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("pay marks the order PAID")
    void payMarksPaid() {
        when(orderRepository.findById(orderId)).thenReturn(Optional.of(order(OrderStatus.PENDING)));

        ToolOrder out = service.pay(customerId, orderId);

        assertThat(out.getStatus()).isEqualTo(OrderStatus.PAID);
        assertThat(out.getPaidAt()).isNotNull();
    }

    @Test
    @DisplayName("cancel is only allowed while pending")
    void cancelOnlyWhenPending() {
        when(orderRepository.findById(orderId)).thenReturn(Optional.of(order(OrderStatus.PAID)));

        assertThatThrownBy(() -> service.cancel(customerId, orderId))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("only the buyer can act on an order")
    void rejectsNonOwner() {
        when(orderRepository.findById(orderId)).thenReturn(Optional.of(order(OrderStatus.PENDING)));

        assertThatThrownBy(() -> service.pay(UUID.randomUUID(), orderId))
                .isInstanceOf(ForbiddenOperationException.class);
    }
}
