package com.giggo.backend.notification.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.notification.domain.DevicePlatform;
import com.giggo.backend.notification.domain.DeviceToken;
import com.giggo.backend.notification.domain.Notification;
import com.giggo.backend.notification.push.PushSender;
import com.giggo.backend.notification.repository.DeviceTokenRepository;
import com.giggo.backend.notification.repository.NotificationRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("NotificationService")
class NotificationServiceTest {

    @Mock NotificationRepository notificationRepository;
    @Mock DeviceTokenRepository deviceTokenRepository;
    @Mock NotificationPreferenceService preferenceService;
    @Mock PushSender pushSender;

    private NotificationService service;

    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new NotificationService(
                notificationRepository, deviceTokenRepository, preferenceService,
                List.of(pushSender), "stub");
    }

    @Test
    @DisplayName("notify persists and pushes to the user's devices")
    void notifyPersistsAndPushes() {
        when(notificationRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(preferenceService.isPushEnabled(eq(userId), any())).thenReturn(true);
        when(deviceTokenRepository.findByUserId(userId)).thenReturn(List.of(
                DeviceToken.builder().token("tok-1").platform(DevicePlatform.ANDROID).build()));

        Notification out = service.notify(userId, "BOOKING_ACCEPTED", "Accepted", "Your booking was accepted", null);

        assertThat(out.getUserId()).isEqualTo(userId);
        assertThat(out.getType()).isEqualTo("BOOKING_ACCEPTED");
        verify(pushSender).send(eq(List.of("tok-1")), anyString(), anyString(), anyMap());
    }

    @Test
    @DisplayName("notify still records in-app but skips push when the category is muted (P8.5)")
    void notifyRespectsDisabledPreference() {
        when(notificationRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(preferenceService.isPushEnabled(eq(userId), any())).thenReturn(false);

        Notification out = service.notify(userId, "PAYMENT_HELD", "Paid", "Funds secured", null);

        assertThat(out).isNotNull(); // in-app inbox entry still created
        verify(pushSender, never()).send(any(), any(), any(), any());
        verify(deviceTokenRepository, never()).findByUserId(any());
    }

    @Test
    @DisplayName("markRead sets readAt for the owner")
    void markReadSetsReadAt() {
        UUID id = UUID.randomUUID();
        Notification n = Notification.builder().id(id).userId(userId)
                .type("X").title("t").body("b").build();
        when(notificationRepository.findById(id)).thenReturn(Optional.of(n));

        Notification out = service.markRead(userId, id);

        assertThat(out.getReadAt()).isNotNull();
    }

    @Test
    @DisplayName("markRead rejects a notification owned by someone else")
    void markReadRejectsNonOwner() {
        UUID id = UUID.randomUUID();
        Notification n = Notification.builder().id(id).userId(UUID.randomUUID())
                .type("X").title("t").body("b").build();
        when(notificationRepository.findById(id)).thenReturn(Optional.of(n));

        assertThatThrownBy(() -> service.markRead(userId, id))
                .isInstanceOf(ForbiddenOperationException.class);
    }

    @Test
    @DisplayName("registerDeviceToken saves the token for the user")
    void registerDeviceTokenSaves() {
        when(deviceTokenRepository.findByToken("tok-9")).thenReturn(Optional.empty());

        service.registerDeviceToken(userId, "tok-9", DevicePlatform.IOS);

        ArgumentCaptor<DeviceToken> captor = ArgumentCaptor.forClass(DeviceToken.class);
        verify(deviceTokenRepository).save(captor.capture());
        assertThat(captor.getValue().getUserId()).isEqualTo(userId);
        assertThat(captor.getValue().getToken()).isEqualTo("tok-9");
        assertThat(captor.getValue().getPlatform()).isEqualTo(DevicePlatform.IOS);
    }
}
