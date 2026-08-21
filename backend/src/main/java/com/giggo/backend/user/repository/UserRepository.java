package com.giggo.backend.user.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.user.domain.User;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);

    // ---- Admin analytics (P11.1) ----
    long countByRole(com.giggo.backend.user.domain.UserRole role);
    long countByCreatedAtAfter(java.time.OffsetDateTime cutoff);
}