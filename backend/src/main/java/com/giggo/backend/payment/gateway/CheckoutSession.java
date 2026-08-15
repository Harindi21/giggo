package com.giggo.backend.payment.gateway;

/** What a gateway returns when a payment is initiated. */
public record CheckoutSession(String gateway, String gatewayRef, String checkoutUrl) {}
