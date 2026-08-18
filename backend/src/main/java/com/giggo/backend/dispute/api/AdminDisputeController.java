package com.giggo.backend.dispute.api;

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

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.dispute.api.dto.DisputeResponse;
import com.giggo.backend.dispute.api.dto.ResolveDisputeRequest;
import com.giggo.backend.dispute.domain.DisputeStatus;
import com.giggo.backend.dispute.service.DisputeService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Admin dispute queue + resolution (P4.6). */
@RestController
@RequestMapping("/api/v1/admin/disputes")
@RequiredArgsConstructor
public class AdminDisputeController {

    private final DisputeService disputeService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<DisputeResponse>> list(
            @RequestParam(defaultValue = "OPEN") DisputeStatus status) {
        return ApiResponse.ok(disputeService.listByStatus(status).stream()
                .map(DisputeResponse::from)
                .toList());
    }

    @PostMapping("/{id}/resolve")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<DisputeResponse> resolve(
            @AuthenticationPrincipal User admin,
            @PathVariable UUID id,
            @Valid @RequestBody ResolveDisputeRequest req) {
        return ApiResponse.ok(DisputeResponse.from(
                disputeService.resolve(admin.getId(), id, req.refund(), req.note())));
    }
}
