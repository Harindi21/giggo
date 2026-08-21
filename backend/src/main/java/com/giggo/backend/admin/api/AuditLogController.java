package com.giggo.backend.admin.api;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.api.dto.AuditLogResponse;
import com.giggo.backend.admin.service.AuditService;
import com.giggo.backend.common.dto.ApiResponse;

import lombok.RequiredArgsConstructor;

/** Admin audit-log viewer (P11.10). */
@RestController
@RequestMapping("/api/v1/admin/audit-log")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditService auditService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<AuditLogResponse>> recent() {
        return ApiResponse.ok(auditService.recent());
    }
}
