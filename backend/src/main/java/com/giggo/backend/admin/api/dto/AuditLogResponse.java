package com.giggo.backend.admin.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.admin.domain.AuditLog;

public record AuditLogResponse(
        UUID id,
        UUID actorId,
        String actorName,
        String action,
        String targetType,
        UUID targetId,
        String detail,
        OffsetDateTime createdAt
) {
    public static AuditLogResponse from(AuditLog log, String actorName) {
        return new AuditLogResponse(
                log.getId(), log.getActorId(), actorName, log.getAction(),
                log.getTargetType(), log.getTargetId(), log.getDetail(), log.getCreatedAt());
    }
}
