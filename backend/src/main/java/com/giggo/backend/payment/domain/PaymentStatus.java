package com.giggo.backend.payment.domain;

/** Payment / escrow lifecycle (P7.1). */
public enum PaymentStatus {
    PENDING,   // initiated, awaiting the gateway to capture funds
    HELD,      // customer paid; funds held by the platform in escrow
    RELEASED,  // escrow released to the provider (minus commission)
    REFUNDED,  // returned to the customer
    FAILED     // the gateway declined / abandoned
}
