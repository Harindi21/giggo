package com.giggo.backend.notification.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

/** Periodically retries failed push deliveries (P8.6). */
@Component
@RequiredArgsConstructor
public class NotificationRetryScheduler {

    private static final Logger log = LoggerFactory.getLogger(NotificationRetryScheduler.class);

    private final NotificationService notificationService;

    @Scheduled(fixedDelayString = "${giggo.notifications.retry-sweep-ms:60000}")
    public void sweep() {
        int retried = notificationService.retryFailed();
        if (retried > 0) {
            log.info("Retried {} failed push notification(s).", retried);
        }
    }
}
