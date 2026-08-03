package com.giggo.backend.user.service;

import com.giggo.backend.common.exception.AuthenticationException;
import com.giggo.backend.user.api.dto.LoginRequest;
import com.giggo.backend.user.api.dto.LoginResponse;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@DisplayName("AuthService – login")
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private JwtService jwtService;
    @Mock
    private RefreshTokenService refreshTokenService;

    @InjectMocks
    private AuthService authService;

    private User verifiedUser;

    @BeforeEach
    void setUp() {
        verifiedUser = User.builder()
                .id(UUID.randomUUID())
                .email("kamal@example.com")
                .phone("+94712345678")
                .passwordHash("hashed-password")
                .fullName("Kamal Silva")
                .role(UserRole.CUSTOMER)
                .active(true)
                .emailVerified(true)
                .createdAt(OffsetDateTime.now())
                .build();
    }

    @Test
    @DisplayName("succeeds with correct credentials and returns tokens")
    void login_success() {
        // given
        when(userRepository.findByEmail("kamal@example.com"))
                .thenReturn(Optional.of(verifiedUser));
        when(passwordEncoder.matches("secret1234", "hashed-password"))
                .thenReturn(true);
        when(jwtService.generateToken(verifiedUser)).thenReturn("access-token");
        when(refreshTokenService.issue(verifiedUser)).thenReturn("refresh-token");

        // when
        LoginResponse response =
                authService.login(new LoginRequest("kamal@example.com", "secret1234"));

        // then
        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.refreshToken()).isEqualTo("refresh-token");
        assertThat(response.user().email()).isEqualTo("kamal@example.com");
    }

    @Test
    @DisplayName("fails when the email does not exist")
    void login_unknownEmail() {
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                authService.login(new LoginRequest("nobody@example.com", "secret1234")))
                .isInstanceOf(AuthenticationException.class)
                .hasMessage("Invalid email or password");

        // no token should ever be issued on failure
        verify(jwtService, never()).generateToken(any());
    }

    @Test
    @DisplayName("fails when the password is wrong")
    void login_wrongPassword() {
        when(userRepository.findByEmail("kamal@example.com"))
                .thenReturn(Optional.of(verifiedUser));
        when(passwordEncoder.matches("wrong", "hashed-password")).thenReturn(false);

        assertThatThrownBy(() ->
                authService.login(new LoginRequest("kamal@example.com", "wrong")))
                .isInstanceOf(AuthenticationException.class)
                .hasMessage("Invalid email or password");
    }

    @Test
    @DisplayName("fails when the email is not verified")
    void login_unverifiedEmail() {
        verifiedUser.setEmailVerified(false);
        when(userRepository.findByEmail("kamal@example.com"))
                .thenReturn(Optional.of(verifiedUser));
        when(passwordEncoder.matches("secret1234", "hashed-password"))
                .thenReturn(true);

        assertThatThrownBy(() ->
                authService.login(new LoginRequest("kamal@example.com", "secret1234")))
                .isInstanceOf(AuthenticationException.class)
                .hasMessageContaining("verify your email");
    }

    @Test
    @DisplayName("locks the account after 5 failed attempts")
    void login_locksAfterFiveFailures() {
        verifiedUser.setFailedLoginAttempts(4); // one more failure = lock
        when(userRepository.findByEmail("kamal@example.com"))
                .thenReturn(Optional.of(verifiedUser));
        when(passwordEncoder.matches("wrong", "hashed-password")).thenReturn(false);

        assertThatThrownBy(() ->
                authService.login(new LoginRequest("kamal@example.com", "wrong")))
                .isInstanceOf(AuthenticationException.class);

        // the 5th failure should have set a lockout timestamp
        assertThat(verifiedUser.getLockoutUntil()).isNotNull();
    }

    @Test
    @DisplayName("rejects login while the account is locked")
    void login_whileLocked() {
        verifiedUser.setLockoutUntil(OffsetDateTime.now().plusMinutes(10));
        when(userRepository.findByEmail("kamal@example.com"))
                .thenReturn(Optional.of(verifiedUser));

        assertThatThrownBy(() ->
                authService.login(new LoginRequest("kamal@example.com", "secret1234")))
                .isInstanceOf(AuthenticationException.class)
                .hasMessageContaining("locked");

        // password isn't even checked when locked
        verify(passwordEncoder, never()).matches(anyString(), anyString());
    }
}