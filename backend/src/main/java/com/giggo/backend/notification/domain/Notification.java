package com.giggo.backend.notification.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** An in-app notification for a user; also delivered as a push when possible. */
@Entity
@Table(name = "notifications")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "type", nullable = false, length = 40)
    private String type;

    @Column(name = "title", nullable = false, length = 150)
    private String title;

    @Column(name = "body", nullable = false, length = 500)
    private String body;

    /** Related booking, when the notification is about one. */
    @Column(name = "booking_id")
    private UUID bookingId;

    /** Null until the user reads it. */
    @Column(name = "read_at")
    private OffsetDateTime readAt;

    // ---- push delivery tracking (P8.6) ----
    @Enumerated(EnumType.STRING)
    @Column(name = "push_status", nullable = false, length = 20)
    @Builder.Default
    private PushStatus pushStatus = PushStatus.PENDING;

    @Column(name = "push_attempts", nullable = false)
    @Builder.Default
    private int pushAttempts = 0;

    @Column(name = "last_attempt_at")
    private OffsetDateTime lastAttemptAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = OffsetDateTime.now();
    }
}
