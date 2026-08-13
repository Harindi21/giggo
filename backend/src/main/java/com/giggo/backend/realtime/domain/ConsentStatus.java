package com.giggo.backend.realtime.domain;

public enum ConsentStatus {
    PENDING,   // requested, awaiting the other party
    GRANTED,   // active sharing until expires_at
    DECLINED,  // other party said no
    REVOKED,   // either party stopped it early
    EXPIRED    // time window elapsed
}
