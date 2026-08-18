package com.giggo.backend.dispute.domain;

/** Dispute lifecycle (P4.6). */
public enum DisputeStatus {
    OPEN,
    RESOLVED_REFUNDED,
    RESOLVED_DISMISSED
}
