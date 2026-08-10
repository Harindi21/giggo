package com.giggo.backend.realtime.api;

import java.security.Principal;
import java.time.OffsetDateTime;
import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

/**
 * Connectivity check for the WebSocket transport: a client sends to
 * {@code /app/ping} and receives the reply on {@code /topic/pong}. Confirms the
 * STOMP pipeline and JWT-authenticated principal are wired correctly.
 */
@Controller
public class PingController {

    @MessageMapping("/ping")
    @SendTo("/topic/pong")
    public Map<String, Object> ping(Principal principal) {
        return Map.of(
                "message", "pong",
                "user", principal != null ? principal.getName() : "anonymous",
                "at", OffsetDateTime.now().toString()
        );
    }
}
