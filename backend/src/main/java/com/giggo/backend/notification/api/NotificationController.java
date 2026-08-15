package com.giggo.backend.notification.api;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.notification.api.dto.NotificationResponse;
import com.giggo.backend.notification.api.dto.RegisterDeviceTokenRequest;
import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** In-app notification inbox + device-token registration (P8.1). */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ApiResponse<List<NotificationResponse>> list(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(notificationService.list(user.getId()).stream()
                .map(NotificationResponse::from)
                .toList());
    }

    @GetMapping("/unread-count")
    public ApiResponse<Map<String, Long>> unreadCount(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(Map.of("count", notificationService.unreadCount(user.getId())));
    }

    @PostMapping("/{id}/read")
    public ApiResponse<NotificationResponse> markRead(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(NotificationResponse.from(notificationService.markRead(user.getId(), id)));
    }

    @PostMapping("/read-all")
    public ApiResponse<Void> markAllRead(@AuthenticationPrincipal User user) {
        notificationService.markAllRead(user.getId());
        return ApiResponse.ok(null);
    }

    @PostMapping("/device-tokens")
    public ApiResponse<Void> registerDeviceToken(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody RegisterDeviceTokenRequest req) {
        notificationService.registerDeviceToken(user.getId(), req.token(), req.platform());
        return ApiResponse.ok(null);
    }
}
