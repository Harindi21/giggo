package com.giggo.backend.payment.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.service.AuditService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.payment.api.dto.CommissionResponse;
import com.giggo.backend.payment.api.dto.SetCommissionRequest;
import com.giggo.backend.payment.service.CommissionService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Admin commission configuration — per-category override of the platform rate (P11.8). */
@RestController
@RequestMapping("/api/v1/admin/commissions")
@RequiredArgsConstructor
public class AdminCommissionController {

    private final CommissionService commissionService;
    private final AuditService auditService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<CommissionResponse>> list() {
        return ApiResponse.ok(commissionService.list());
    }

    @PutMapping("/{categoryId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<CommissionResponse> set(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID categoryId, @Valid @RequestBody SetCommissionRequest req) {
        CommissionResponse result = commissionService.setRate(categoryId, req.rate());
        auditService.record(admin.getId(), "COMMISSION_SET", "CATEGORY", categoryId,
                "rate=" + req.rate());
        return ApiResponse.ok(result);
    }

    @DeleteMapping("/{categoryId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<CommissionResponse> clear(
            @AuthenticationPrincipal User admin, @PathVariable UUID categoryId) {
        CommissionResponse result = commissionService.clearRate(categoryId);
        auditService.record(admin.getId(), "COMMISSION_CLEARED", "CATEGORY", categoryId, null);
        return ApiResponse.ok(result);
    }
}
