package com.giggo.backend.notification.domain;

/** Delivery state of a notification's push (P8.6). */
public enum PushStatus {
    PENDING,  // not yet attempted
    SENT,     // handed to the push provider successfully
    FAILED,   // the provider call failed; eligible for retry
    SKIPPED   // no push wanted — preference off or no registered devices
}
