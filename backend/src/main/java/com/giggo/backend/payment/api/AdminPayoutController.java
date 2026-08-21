package com.giggo.backend.payment.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.service.AuditService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.payment.api.dto.PayoutResponse;
import com.giggo.backend.payment.api.dto.ProcessPayoutRequest;
import com.giggo.backend.payment.api.dto.RejectPayoutRequest;
import com.giggo.backend.payment.domain.PayoutStatus;
import com.giggo.backend.payment.service.PayoutService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Admin payout processing queue (P11.9). */
@RestController
@RequestMapping("/api/v1/admin/payouts")
@RequiredArgsConstructor
public class AdminPayoutController {

    private final PayoutService payoutService;
    private final AuditService auditService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<PayoutResponse>> list(
            @RequestParam(defaultValue = "REQUESTED") PayoutStatus status) {
        return ApiResponse.ok(payoutService.adminList(status));
    }

    @PostMapping("/{id}/process")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PayoutResponse> process(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID id, @Valid @RequestBody ProcessPayoutRequest req) {
        PayoutResponse result = PayoutResponse.from(payoutService.process(id, req.reference()));
        auditService.record(admin.getId(), "PAYOUT_PAID", "PAYOUT", id, "ref=" + req.reference());
        return ApiResponse.ok(result);
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PayoutResponse> reject(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID id, @Valid @RequestBody RejectPayoutRequest req) {
        PayoutResponse result = PayoutResponse.from(payoutService.reject(id, req.note()));
        auditService.record(admin.getId(), "PAYOUT_REJECTED", "PAYOUT", id, req.note());
        return ApiResponse.ok(result);
    }
}
