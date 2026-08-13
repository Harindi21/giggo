package com.giggo.backend.common.exception;

/** Thrown when an authenticated user tries an action they are not a party to (HTTP 403). */
public class ForbiddenOperationException extends RuntimeException {
    public ForbiddenOperationException(String message) {
        super(message);
    }
}
