package com.giggo.backend.payment.gateway;

import com.giggo.backend.payment.domain.Payment;

/**
 * Payment gateway seam (P7.1). The default {@link StubPaymentGateway} lets the
 * whole escrow flow run without any credentials. A real PayHere adapter would
 * implement this same interface: {@code initiate} creates a PayHere checkout
 * (order id + hosted URL) and a {@code /payments/notify} webhook verifies the
 * md5 signature and confirms capture. Select the active gateway with
 * {@code giggo.payments.gateway}.
 */
public interface PaymentGateway {

    /** Gateway id stored on the payment, e.g. "stub" or "payhere". */
    String name();

    /** Create a checkout session the customer is sent to in order to pay. */
    CheckoutSession initiate(Payment payment);
}
