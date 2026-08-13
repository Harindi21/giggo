package com.giggo.backend.realtime.config;

import java.util.List;
import java.util.UUID;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.stereotype.Component;

import com.giggo.backend.user.service.JwtService;

import lombok.RequiredArgsConstructor;

/**
 * Authenticates the STOMP CONNECT frame with the same JWT the REST API uses.
 * The token is read from the "Authorization: Bearer ..." STOMP header; on
 * success the user's id is attached as the session Principal so later frames
 * (location updates, subscriptions) know who is sending them.
 */
@Component
@RequiredArgsConstructor
public class StompAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = bearerToken(accessor);
            UUID userId = (token == null) ? null : jwtService.extractUserId(token);
            if (userId == null) {
                throw new IllegalArgumentException("Missing or invalid authentication token");
            }
            accessor.setUser(new StompPrincipal(userId.toString()));
        }
        return message;
    }

    private String bearerToken(StompHeaderAccessor accessor) {
        List<String> header = accessor.getNativeHeader("Authorization");
        if (header == null || header.isEmpty() || header.get(0) == null) {
            return null;
        }
        String value = header.get(0);
        return value.startsWith("Bearer ") ? value.substring(7) : value;
    }
}
