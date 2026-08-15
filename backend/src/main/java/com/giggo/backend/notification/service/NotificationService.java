package com.giggo.backend.notification.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.notification.domain.DevicePlatform;
import com.giggo.backend.notification.domain.DeviceToken;
import com.giggo.backend.notification.domain.Notification;
import com.giggo.backend.notification.push.PushSender;
import com.giggo.backend.notification.repository.DeviceTokenRepository;
import com.giggo.backend.notification.repository.NotificationRepository;

/**
 * Creates in-app notifications and delivers them as pushes (P8.1). The push
 * provider is pluggable (stub by default; FCM seam).
 */
@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final PushSender pushSender;

    public NotificationService(
            NotificationRepository notificationRepository,
            DeviceTokenRepository deviceTokenRepository,
            List<PushSender> pushSenders,
            @Value("${giggo.notifications.push-provider:stub}") String provider) {
        this.notificationRepository = notificationRepository;
        this.deviceTokenRepository = deviceTokenRepository;
        this.pushSender = pushSenders.stream()
                .filter(p -> provider.equalsIgnoreCase(p.name()))
                .findFirst()
                .orElse(pushSenders.get(0));
    }

    /**
     * Persist a notification for a user and push it to their devices. Runs in its
     * own transaction so it can be called from an after-commit event listener.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public Notification notify(UUID userId, String type, String title, String body, UUID bookingId) {
        Notification saved = notificationRepository.save(Notification.builder()
                .userId(userId)
                .type(type)
                .title(title)
                .body(body)
                .bookingId(bookingId)
                .build());

        List<String> tokens = deviceTokenRepository.findByUserId(userId).stream()
                .map(DeviceToken::getToken)
                .toList();
        Map<String, String> data = bookingId == null
                ? Map.of("type", type)
                : Map.of("type", type, "bookingId", bookingId.toString());
        pushSender.send(tokens, title, body, data);
        return saved;
    }

    @Transactional(readOnly = true)
    public List<Notification> list(UUID userId) {
        return notificationRepository.findTop50ByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public long unreadCount(UUID userId) {
        return notificationRepository.countByUserIdAndReadAtIsNull(userId);
    }

    @Transactional
    public Notification markRead(UUID userId, UUID notificationId) {
        Notification n = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        if (!n.getUserId().equals(userId)) {
            throw new ForbiddenOperationException("Not your notification");
        }
        if (n.getReadAt() == null) {
            n.setReadAt(OffsetDateTime.now());
            notificationRepository.save(n);
        }
        return n;
    }

    @Transactional
    public void markAllRead(UUID userId) {
        notificationRepository.markAllRead(userId, OffsetDateTime.now());
    }

    @Transactional
    public void registerDeviceToken(UUID userId, String token, DevicePlatform platform) {
        DeviceToken device = deviceTokenRepository.findByToken(token)
                .orElseGet(() -> DeviceToken.builder().token(token).build());
        device.setUserId(userId);
        device.setPlatform(platform);
        deviceTokenRepository.save(device);
    }
}
