package com.giggo.backend.admin.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** An append-only record of a privileged admin action (P11.10). */
@Entity
@Table(name = "audit_log")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AuditLog {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "actor_id", nullable = false)
    private UUID actorId;

    /** e.g. KYC_APPROVED, DISPUTE_RESOLVED, PAYOUT_PAID. */
    @Column(name = "action", nullable = false, length = 60)
    private String action;

    /** e.g. KYC, DISPUTE, REVIEW, PAYOUT, CATEGORY. */
    @Column(name = "target_type", length = 40)
    private String targetType;

    @Column(name = "target_id")
    private UUID targetId;

    @Column(name = "detail", length = 500)
    private String detail;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = OffsetDateTime.now();
    }
}
