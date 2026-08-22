package com.giggo.backend.user.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.admin.service.AuditService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.user.api.dto.UserResponse;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;
import com.giggo.backend.user.service.AdminUserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserRepository userRepository;
    private final AdminUserService adminUserService;
    private final AuditService auditService;

    @GetMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<UserResponse>> listAllUsers() {
        List<UserResponse> users = userRepository.findAll()
                .stream()
                .map(UserResponse::from)
                .toList();
        return ApiResponse.ok(users);
    }

    /** Suspend an account — drops the user out of search and blocks their actions (P11.4). */
    @PostMapping("/users/{id}/suspend")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<UserResponse> suspend(
            @AuthenticationPrincipal User admin, @PathVariable UUID id) {
        UserResponse result = UserResponse.from(adminUserService.setActive(id, false));
        auditService.record(admin.getId(), "USER_SUSPENDED", "USER", id, null);
        return ApiResponse.ok(result);
    }

    /** Reactivate a suspended account (P11.4). */
    @PostMapping("/users/{id}/reactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<UserResponse> reactivate(
            @AuthenticationPrincipal User admin, @PathVariable UUID id) {
        UserResponse result = UserResponse.from(adminUserService.setActive(id, true));
        auditService.record(admin.getId(), "USER_REACTIVATED", "USER", id, null);
        return ApiResponse.ok(result);
    }
}
