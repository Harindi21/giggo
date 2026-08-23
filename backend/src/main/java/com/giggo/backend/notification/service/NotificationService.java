package com.giggo.backend.notification.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.notification.domain.DevicePlatform;
import com.giggo.backend.notification.domain.DeviceToken;
import com.giggo.backend.notification.domain.Notification;
import com.giggo.backend.notification.domain.NotificationCategory;
import com.giggo.backend.notification.domain.PushStatus;
import com.giggo.backend.notification.push.PushSender;
import com.giggo.backend.notification.repository.DeviceTokenRepository;
import com.giggo.backend.notification.repository.NotificationRepository;

/**
 * Creates in-app notifications and delivers them as pushes (P8.1). The push
 * provider is pluggable (stub by default; FCM seam).
 */
@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final NotificationPreferenceService preferenceService;
    private final PushSender pushSender;
    private final int maxPushAttempts;

    public NotificationService(
            NotificationRepository notificationRepository,
            DeviceTokenRepository deviceTokenRepository,
            NotificationPreferenceService preferenceService,
            List<PushSender> pushSenders,
            @Value("${giggo.notifications.push-provider:stub}") String provider,
            @Value("${giggo.notifications.max-push-attempts:3}") int maxPushAttempts) {
        this.notificationRepository = notificationRepository;
        this.deviceTokenRepository = deviceTokenRepository;
        this.preferenceService = preferenceService;
        this.maxPushAttempts = maxPushAttempts;
        this.pushSender = pushSenders.stream()
                .filter(p -> provider.equalsIgnoreCase(p.name()))
                .findFirst()
                .orElse(pushSenders.get(0));
    }

    /**
     * Persist a notification for a user and attempt to push it. Runs in its own
     * transaction so it can be called from an after-commit event listener. The
     * in-app inbox entry is always kept; the push is tracked and retryable (P8.6).
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
        return deliver(saved);
    }

    /** Retry pushes that previously failed and are still under the attempt cap (P8.6). */
    @Transactional
    public int retryFailed() {
        List<Notification> failed = notificationRepository
                .findTop100ByPushStatusAndPushAttemptsLessThanOrderByCreatedAtAsc(
                        PushStatus.FAILED, maxPushAttempts);
        failed.forEach(this::deliver);
        return failed.size();
    }

    /**
     * Attempt push delivery for a notification and record the outcome. Push is
     * skipped (never failed) when the user muted the category (P8.5) or has no
     * registered devices; a provider error is recorded as FAILED for retry.
     */
    private Notification deliver(Notification n) {
        if (!preferenceService.isPushEnabled(n.getUserId(), NotificationCategory.of(n.getType()))) {
            n.setPushStatus(PushStatus.SKIPPED);
            return notificationRepository.save(n);
        }
        List<String> tokens = deviceTokenRepository.findByUserId(n.getUserId()).stream()
                .map(DeviceToken::getToken)
                .toList();
        if (tokens.isEmpty()) {
            n.setPushStatus(PushStatus.SKIPPED);
            return notificationRepository.save(n);
        }
        n.setPushAttempts(n.getPushAttempts() + 1);
        n.setLastAttemptAt(OffsetDateTime.now());
        Map<String, String> data = n.getBookingId() == null
                ? Map.of("type", n.getType())
                : Map.of("type", n.getType(), "bookingId", n.getBookingId().toString());
        try {
            pushSender.send(tokens, n.getTitle(), n.getBody(), data);
            n.setPushStatus(PushStatus.SENT);
        } catch (Exception ex) {
            n.setPushStatus(PushStatus.FAILED);
            log.warn("Push delivery failed for notification {} (attempt {}): {}",
                    n.getId(), n.getPushAttempts(), ex.getMessage());
        }
        return notificationRepository.save(n);
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
