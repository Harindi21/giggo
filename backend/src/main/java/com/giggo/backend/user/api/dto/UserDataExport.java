package com.giggo.backend.user.api.dto;

import java.time.OffsetDateTime;

import com.giggo.backend.user.domain.User;

public record UserDataExport(
        String exportGeneratedAt,
        String id,
        String email,
        String phone,
        String fullName,
        String role,
        boolean emailVerified,
        boolean active,
        OffsetDateTime accountCreatedAt
) {
    public static UserDataExport from(User user) {
        return new UserDataExport(
                OffsetDateTime.now().toString(),
                user.getId().toString(),
                user.getEmail(),
                user.getPhone(),
                user.getFullName(),
                user.getRole().name(),
                user.isEmailVerified(),
                user.isActive(),
                user.getCreatedAt()
        );
    }
}