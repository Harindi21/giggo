package com.giggo.backend.admin.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.admin.api.dto.AuditLogResponse;
import com.giggo.backend.admin.domain.AuditLog;
import com.giggo.backend.admin.repository.AuditLogRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuditService")
class AuditServiceTest {

    @Mock AuditLogRepository auditLogRepository;
    @Mock UserRepository userRepository;

    private AuditService service;

    private final UUID actorId = UUID.randomUUID();
    private final UUID targetId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new AuditService(auditLogRepository, userRepository);
    }

    @Test
    @DisplayName("record persists the action with its actor and target")
    void records() {
        service.record(actorId, "KYC_APPROVED", "KYC", targetId, "ok");

        ArgumentCaptor<AuditLog> captor = ArgumentCaptor.forClass(AuditLog.class);
        verify(auditLogRepository).save(captor.capture());
        AuditLog saved = captor.getValue();
        assertThat(saved.getActorId()).isEqualTo(actorId);
        assertThat(saved.getAction()).isEqualTo("KYC_APPROVED");
        assertThat(saved.getTargetType()).isEqualTo("KYC");
        assertThat(saved.getTargetId()).isEqualTo(targetId);
    }

    @Test
    @DisplayName("record never throws, even if persistence fails")
    void recordFailsSoft() {
        when(auditLogRepository.save(any())).thenThrow(new RuntimeException("db down"));
        assertThatCode(() -> service.record(actorId, "X", "Y", targetId, null))
                .doesNotThrowAnyException();
    }

    @Test
    @DisplayName("recent resolves the actor's display name")
    void recentResolvesNames() {
        AuditLog log = AuditLog.builder().id(UUID.randomUUID()).actorId(actorId)
                .action("PAYOUT_PAID").targetType("PAYOUT").targetId(targetId).build();
        when(auditLogRepository.findTop200ByOrderByCreatedAtDesc()).thenReturn(List.of(log));
        when(userRepository.findAllById(any())).thenReturn(List.of(
                User.builder().id(actorId).fullName("Admin Ann").build()));

        List<AuditLogResponse> out = service.recent();

        assertThat(out).singleElement().satisfies(r -> {
            assertThat(r.action()).isEqualTo("PAYOUT_PAID");
            assertThat(r.actorName()).isEqualTo("Admin Ann");
        });
    }
}
