package com.giggo.backend.user.service;

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

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;

    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email().trim().toLowerCase())
                .orElseThrow(() -> new AuthenticationException(INVALID));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new AuthenticationException(INVALID);
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