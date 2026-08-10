package com.giggo.backend.realtime.config;

import java.security.Principal;

/** Authenticated STOMP user — {@code name} holds the user's UUID as a string. */
public record StompPrincipal(String name) implements Principal {
    @Override
    public String getName() {
        return name;
    }
}
