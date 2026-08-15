package com.giggo.backend.notification.push;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Default, credential-free push sender (P8.1). Logs what would be delivered so
 * the notification flow is fully exercisable in development and demos. Swap in
 * an FCM adapter by implementing {@link PushSender} and setting
 * {@code giggo.notifications.push-provider=fcm}.
 */
@Component
public class StubPushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(StubPushSender.class);

    @Override
    public String name() {
        return "stub";
    }

    @Override
    public void send(List<String> tokens, String title, String body, Map<String, String> data) {
        if (tokens.isEmpty()) {
            return;
        }
        log.info("[push:stub] -> {} device(s): \"{}\" — {} {}", tokens.size(), title, body, data);
    }
}
