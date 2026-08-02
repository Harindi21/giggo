package com.giggo.backend.user.service;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.DuplicateResourceException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.user.api.dto.RegisterRequest;
import com.giggo.backend.user.api.dto.UpdateProfileRequest;
import com.giggo.backend.user.api.dto.UserResponse;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailVerificationService emailVerificationService;

    @Transactional
    public UserResponse register(RegisterRequest request) {
        String email = request.email().trim().toLowerCase();
        String phone = normalisePhone(request.phone());

        if (userRepository.existsByEmail(email)) {
            throw new DuplicateResourceException("An account with this email already exists");
        }
        if (userRepository.existsByPhone(phone)) {
            throw new DuplicateResourceException("An account with this phone number already exists");
        }

        User user = User.builder()
                .email(email)
                .phone(phone)
                .passwordHash(passwordEncoder.encode(request.password()))
                .fullName(request.fullName().trim())
                .role(resolveRole(request.role()))
                .active(true)
                .build();

        User saved = userRepository.save(user);
        emailVerificationService.issueCode(saved);
        return UserResponse.from(saved);
    }

    @Transactional
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setFullName(request.fullName().trim());
        return UserResponse.from(user); // JPA saves the change on commit
    }

    /** Stores every number in one canonical form: +947XXXXXXXX */
    private String normalisePhone(String raw) {
        String cleaned = raw.trim().replaceAll("[\\s-]", "");
        return cleaned.startsWith("0") ? "+94" + cleaned.substring(1) : cleaned;
    }

    private UserRole resolveRole(String requested) {
        if (requested == null || requested.isBlank()) {
            return UserRole.CUSTOMER;
        }
        UserRole role;
        try {
            role = UserRole.valueOf(requested.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Role must be CUSTOMER or PROVIDER");
        }
        if (role == UserRole.ADMIN) {
            throw new IllegalArgumentException("Role must be CUSTOMER or PROVIDER");
        }
        return role;
    }
}