package com.giggo.backend.user.api;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.user.api.dto.LoginRequest;
import com.giggo.backend.user.api.dto.LoginResponse;
import com.giggo.backend.user.api.dto.RegisterRequest;
import com.giggo.backend.user.api.dto.ResendCodeRequest;
import com.giggo.backend.user.api.dto.UserResponse;
import com.giggo.backend.user.api.dto.VerifyEmailRequest;
import com.giggo.backend.user.service.AuthService;
import com.giggo.backend.user.service.EmailVerificationService;
import com.giggo.backend.user.service.UserService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final AuthService authService;
    private final EmailVerificationService emailVerificationService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok(userService.register(request));
    }

    @PostMapping("/verify-email")
    public ApiResponse<Void> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        emailVerificationService.verify(request.email(), request.code());
        return ApiResponse.ok(null);
    }

    @PostMapping("/resend-verification")
    public ApiResponse<Void> resendCode(@Valid @RequestBody ResendCodeRequest request) {
        emailVerificationService.resend(request.email());
        return ApiResponse.ok(null);
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }
}
