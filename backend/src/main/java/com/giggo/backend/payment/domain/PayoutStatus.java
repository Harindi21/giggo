package com.giggo.backend.payment.domain;

/** Provider payout (withdrawal) lifecycle (P7.6). */
public enum PayoutStatus {
    REQUESTED, // provider asked to withdraw; funds reserved out of available balance
    PAID,      // admin completed the bank transfer
    REJECTED   // admin declined; funds return to the available balance
}
