package com.giggo.backend.realtime.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import lombok.RequiredArgsConstructor;

/**
 * STOMP-over-WebSocket transport for real-time job tracking (P5).
 *
 * <p>Clients connect to {@code /ws} (raw WebSocket, used by the Flutter app) or
 * {@code /ws-sockjs} (SockJS fallback for web). Server broadcasts on {@code /topic/**}
 * and {@code /user/**}; clients send to {@code /app/**}. Phase 1 uses the in-memory
 * simple broker (correct for a single instance / free tier). For horizontal scale,
 * swap {@code enableSimpleBroker} for a STOMP relay (RabbitMQ) or a Redis relay —
 * the destinations and client code stay identical.
 */
@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final StompAuthChannelInterceptor authInterceptor;

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*");
        registry.addEndpoint("/ws-sockjs").setAllowedOriginPatterns("*").withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.setApplicationDestinationPrefixes("/app");
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(authInterceptor);
    }
}
