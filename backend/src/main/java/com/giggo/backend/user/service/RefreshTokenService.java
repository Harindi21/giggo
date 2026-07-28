package com.giggo.backend.user.service;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.Base64;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.config.JwtProperties;
import com.giggo.backend.common.exception.AuthenticationException;
import com.giggo.backend.user.domain.RefreshToken;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.RefreshTokenRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private final SecureRandom random = new SecureRandom();
    private final Base64.Encoder encoder = Base64.getUrlEncoder().withoutPadding();

    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProperties jwtProperties;

    /** Creates a new refresh token, stores its HASH, and returns the RAW token to send to the client. */
    @Transactional
    public String issue(User user) {
        byte[] bytes = new byte[48];
        random.nextBytes(bytes);
        String rawToken = encoder.encodeToString(bytes);

        refreshTokenRepository.save(RefreshToken.builder()
                .user(user)
                .tokenHash(passwordEncoder.encode(rawToken))
                .expiresAt(OffsetDateTime.now().plusDays(jwtProperties.refreshExpirationDays()))
                .build());

        return rawToken;
    }

    /** Validates a raw refresh token and returns the owning user. Rotates the token (revokes old). */
    @Transactional
    public User validateAndRotate(String rawToken) {
        RefreshToken stored = findMatching(rawToken)
                .orElseThrow(() -> new AuthenticationException("Invalid refresh token"));

        if (!stored.isUsable()) {
            throw new AuthenticationException("Refresh token expired or revoked");
        }

        stored.setRevokedAt(OffsetDateTime.now()); // rotation: this token is now single-use
        refreshTokenRepository.save(stored);

        return stored.getUser();
    }

    @Transactional
    public void revokeAll(User user) {
        refreshTokenRepository.revokeAllForUser(user.getId());
    }

    /**
     * We can't look up by raw token (we only stored hashes), and BCrypt hashes aren't reversible,
     * so we check the token against candidate rows. Kept simple here; optimised later if needed.
     */
    private java.util.Optional<RefreshToken> findMatching(String rawToken) {
        return refreshTokenRepository.findAll().stream()
                .filter(rt -> rt.getRevokedAt() == null)
                .filter(rt -> passwordEncoder.matches(rawToken, rt.getTokenHash()))
                .findFirst();
    }
}