package com.giggo.backend.realtime.config;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.MessageBuilder;

import com.giggo.backend.user.service.JwtService;

@ExtendWith(MockitoExtension.class)
@DisplayName("StompAuthChannelInterceptor – CONNECT auth")
class StompAuthChannelInterceptorTest {

    @Mock
    private JwtService jwtService;
    @InjectMocks
    private StompAuthChannelInterceptor interceptor;

    private final MessageChannel channel = mock(MessageChannel.class);

    private StompHeaderAccessor connect(String authHeader) {
        StompHeaderAccessor accessor = StompHeaderAccessor.create(StompCommand.CONNECT);
        accessor.setLeaveMutable(true);
        if (authHeader != null) {
            accessor.addNativeHeader("Authorization", authHeader);
        }
        return accessor;
    }

    @Test
    @DisplayName("valid token attaches the user id as the STOMP principal")
    void validTokenSetsPrincipal() {
        UUID userId = UUID.randomUUID();
        when(jwtService.extractUserId("good-token")).thenReturn(userId);

        StompHeaderAccessor accessor = connect("Bearer good-token");
        Message<byte[]> msg = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());

        interceptor.preSend(msg, channel);

        assertThat(accessor.getUser()).isNotNull();
        assertThat(accessor.getUser().getName()).isEqualTo(userId.toString());
    }

    @Test
    @DisplayName("invalid token is rejected")
    void invalidTokenRejected() {
        when(jwtService.extractUserId("bad-token")).thenReturn(null);

        StompHeaderAccessor accessor = connect("Bearer bad-token");
        Message<byte[]> msg = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());

        assertThatThrownBy(() -> interceptor.preSend(msg, channel))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("missing token is rejected")
    void missingTokenRejected() {
        StompHeaderAccessor accessor = connect(null);
        Message<byte[]> msg = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());

        assertThatThrownBy(() -> interceptor.preSend(msg, channel))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("non-CONNECT frames pass through untouched")
    void nonConnectPassesThrough() {
        StompHeaderAccessor accessor = StompHeaderAccessor.create(StompCommand.SEND);
        accessor.setLeaveMutable(true);
        accessor.setDestination("/app/ping");
        Message<byte[]> msg = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());

        Message<?> out = interceptor.preSend(msg, channel);

        assertThat(out).isSameAs(msg);
        assertThat(accessor.getUser()).isNull();
    }
}
