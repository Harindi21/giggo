package com.giggo.backend.admin.service;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.admin.api.dto.AuditLogResponse;
import com.giggo.backend.admin.domain.AuditLog;
import com.giggo.backend.admin.repository.AuditLogRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Records privileged admin actions and serves the audit-log viewer (P11.10).
 * Recording is best-effort: a logging failure must never break the action it
 * describes, which has already been committed by its own service.
 */
@Service
@RequiredArgsConstructor
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger(AuditService.class);

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public void record(UUID actorId, String action, String targetType, UUID targetId, String detail) {
        try {
            auditLogRepository.save(AuditLog.builder()
                    .actorId(actorId)
                    .action(action)
                    .targetType(targetType)
                    .targetId(targetId)
                    .detail(truncate(detail))
                    .build());
        } catch (Exception ex) {
            log.warn("Could not record audit entry {} by {}: {}", action, actorId, ex.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> recent() {
        List<AuditLog> logs = auditLogRepository.findTop200ByOrderByCreatedAtDesc();
        Set<UUID> actorIds = logs.stream().map(AuditLog::getActorId).collect(Collectors.toSet());
        Map<UUID, String> names = userRepository.findAllById(actorIds).stream()
                .collect(Collectors.toMap(User::getId, User::getFullName));
        return logs.stream()
                .map(l -> AuditLogResponse.from(l, names.get(l.getActorId())))
                .toList();
    }

    private static String truncate(String detail) {
        if (detail == null) {
            return null;
        }
        return detail.length() <= 500 ? detail : detail.substring(0, 500);
    }
}
