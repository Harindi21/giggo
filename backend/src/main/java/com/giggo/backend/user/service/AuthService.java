package com.giggo.backend.user.service;

import java.time.Duration;
import java.time.OffsetDateTime;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.AuthenticationException;
import com.giggo.backend.user.api.dto.LoginRequest;
import com.giggo.backend.user.api.dto.LoginResponse;
import com.giggo.backend.user.api.dto.UserResponse;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String INVALID = "Invalid email or password";
    private static final int MAX_ATTEMPTS = 5;
    private static final Duration LOCK_DURATION = Duration.ofMinutes(15);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email().trim().toLowerCase())
                .orElseThrow(() -> new AuthenticationException(INVALID));

        // 1. Is the account currently locked?
        if (user.getLockoutUntil() != null
                && user.getLockoutUntil().isAfter(OffsetDateTime.now())) {
            long minutes = Duration.between(OffsetDateTime.now(), user.getLockoutUntil())
                    .toMinutes() + 1;
            throw new AuthenticationException(
                    "Account locked due to too many failed attempts. Try again in "
                            + minutes + " minute(s).");
        }

        // 2. Wrong password -> record a failed attempt.
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            registerFailedAttempt(user);
            throw new AuthenticationException(INVALID);
        }

        // 3. Correct password -> clear any failure history.
        if (user.getFailedLoginAttempts() > 0 || user.getLockoutUntil() != null) {
            user.setFailedLoginAttempts(0);
            user.setLockoutUntil(null);
            userRepository.save(user);
        }

        if (!user.isEmailVerified()) {
            throw new AuthenticationException("Please verify your email before logging in");
        }
        if (!user.isActive()) {
            throw new AuthenticationException("This account has been deactivated");
        }

        String accessToken = jwtService.generateToken(user);
        String refreshToken = refreshTokenService.issue(user);
        return LoginResponse.of(accessToken, refreshToken, UserResponse.from(user));
    }

    private void registerFailedAttempt(User user) {
        int attempts = user.getFailedLoginAttempts() + 1;
        if (attempts >= MAX_ATTEMPTS) {
            user.setFailedLoginAttempts(0);           // reset counter; the lock takes over
            user.setLockoutUntil(OffsetDateTime.now().plus(LOCK_DURATION));
        } else {
            user.setFailedLoginAttempts(attempts);
        }
        userRepository.save(user);
    }

    @Transactional
    public LoginResponse refresh(String rawRefreshToken) {
        User user = refreshTokenService.validateAndRotate(rawRefreshToken);
        String accessToken = jwtService.generateToken(user);
        String newRefreshToken = refreshTokenService.issue(user);
        return LoginResponse.of(accessToken, newRefreshToken, UserResponse.from(user));
    }

    public void logout(User user) {
        refreshTokenService.revokeAll(user);
    }
}