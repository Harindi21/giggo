package com.giggo.backend.user.api.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.domain.UserRole;

public record UserResponse(
        UUID id,
        String email,
        String phone,
        String fullName,
        UserRole role,
        boolean active,
        OffsetDateTime createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getPhone(),
                user.getFullName(),
                user.getRole(),
                user.isActive(),
                user.getCreatedAt()
        );
    }
}