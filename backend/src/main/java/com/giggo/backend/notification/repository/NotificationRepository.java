package com.giggo.backend.notification.repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giggo.backend.notification.domain.Notification;
import com.giggo.backend.notification.domain.PushStatus;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findTop50ByUserIdOrderByCreatedAtDesc(UUID userId);

    long countByUserIdAndReadAtIsNull(UUID userId);

    /** Failed pushes still under the attempt cap, for the retry sweep (P8.6). */
    List<Notification> findTop100ByPushStatusAndPushAttemptsLessThanOrderByCreatedAtAsc(
            PushStatus status, int maxAttempts);

    @Modifying
    @Query("UPDATE Notification n SET n.readAt = :now WHERE n.userId = :userId AND n.readAt IS NULL")
    int markAllRead(@Param("userId") UUID userId, @Param("now") OffsetDateTime now);
}
