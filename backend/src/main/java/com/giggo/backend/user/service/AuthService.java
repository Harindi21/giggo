package com.giggo.backend.user.service;

import com.giggo.backend.common.exception.AuthenticationException;
import com.giggo.backend.user.api.dto.LoginRequest;
import com.giggo.backend.user.api.dto.LoginResponse;
import com.giggo.backend.user.api.dto.UserResponse;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String INVALID = "Invalid email or password";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

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

        String token = jwtService.generateToken(user);
        return LoginResponse.of(token, UserResponse.from(user));
    }
}