package com.giggo.backend.payment.gateway;

import java.math.BigDecimal;

/**
 * Payment gateway seam (P7.1). The default {@link StubPaymentGateway} lets the
 * whole flow run without any credentials. A real PayHere adapter would implement
 * this same interface: {@code initiate} creates a PayHere checkout (order id +
 * hosted URL) and a {@code /payments/notify} webhook verifies the md5 signature
 * and confirms capture. Select the active gateway with {@code giggo.payments.gateway}.
 *
 * <p>Used by both booking escrow (P7) and tool-marketplace orders (P10).
 */
public interface PaymentGateway {

    /** Gateway id stored on the payment/order, e.g. "stub" or "payhere". */
    String name();

    /** Create a checkout session the customer is sent to in order to pay. */
    CheckoutSession initiate(BigDecimal amount, String currency);
}
