package com.giggo.backend.marketplace.api;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.marketplace.api.dto.OrderResponse;
import com.giggo.backend.marketplace.api.dto.PlaceOrderRequest;
import com.giggo.backend.marketplace.service.OrderService;
import com.giggo.backend.marketplace.service.OrderService.OrderResult;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Tool marketplace orders (P10.3). Any authenticated user can buy tools. */
@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<OrderResponse> place(
            @AuthenticationPrincipal User user, @Valid @RequestBody PlaceOrderRequest req) {
        OrderResult result = orderService.place(user.getId(), req);
        return ApiResponse.ok(OrderResponse.of(result.order(), result.checkoutUrl()));
    }

    @GetMapping
    public ApiResponse<List<OrderResponse>> list(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(orderService.listMine(user.getId()).stream()
                .map(OrderResponse::from)
                .toList());
    }

    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> get(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(OrderResponse.from(orderService.getForCustomer(user.getId(), id)));
    }

    @PostMapping("/{id}/pay")
    public ApiResponse<OrderResponse> pay(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(OrderResponse.from(orderService.pay(user.getId(), id)));
    }

    @PostMapping("/{id}/cancel")
    public ApiResponse<OrderResponse> cancel(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(OrderResponse.from(orderService.cancel(user.getId(), id)));
    }
}
