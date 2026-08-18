package com.giggo.backend.marketplace.domain;

/** Tool order lifecycle (P10.3). */
public enum OrderStatus {
    PENDING,   // placed, awaiting payment
    PAID,      // paid for
    CANCELLED  // cancelled before payment
}
