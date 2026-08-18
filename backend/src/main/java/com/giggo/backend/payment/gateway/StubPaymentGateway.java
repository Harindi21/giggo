package com.giggo.backend.payment.gateway;

import java.math.BigDecimal;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Default, credential-free gateway (P7.1). Produces a deterministic reference
 * and a placeholder checkout URL so the escrow flow is fully exercisable in
 * development and demos. Capture is completed by calling the confirm endpoint
 * (which stands in for the gateway's server-to-server notification).
 */
@Component
public class StubPaymentGateway implements PaymentGateway {

    private final String checkoutBase;

    public StubPaymentGateway(
            @Value("${giggo.payments.stub-checkout-base:https://sandbox.payments.local/checkout}")
            String checkoutBase) {
        this.checkoutBase = checkoutBase;
    }

    @Override
    public String name() {
        return "stub";
    }

    @Override
    public CheckoutSession initiate(BigDecimal amount, String currency) {
        String ref = "STUB-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase();
        String url = "%s?ref=%s&amount=%s&currency=%s".formatted(
                checkoutBase, ref, amount.toPlainString(), currency);
        return new CheckoutSession(name(), ref, url);
    }
}
