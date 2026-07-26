package com.giggo.backend.user.service;

import com.giggo.backend.common.email.EmailSender;
import com.giggo.backend.common.exception.InvalidOtpException;
import com.giggo.backend.common.exception.TooManyRequestsException;
import com.giggo.backend.user.domain.EmailVerificationToken;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.EmailVerificationTokenRepository;
import com.giggo.backend.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
public class EmailVerificationService {

    private static final Duration VALIDITY = Duration.ofMinutes(10);
    private static final Duration RESEND_COOLDOWN = Duration.ofSeconds(60);
    private static final int MAX_ATTEMPTS = 5;
    private static final String GENERIC_FAILURE = "Invalid or expired code";

    private final SecureRandom random = new SecureRandom();

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailSender emailSender;

    @Transactional
    public void issueCode(User user) {
        tokenRepository.deleteByUserId(user.getId());

        String code = String.format("%06d", random.nextInt(1_000_000));

        tokenRepository.save(EmailVerificationToken.builder()
                .user(user)
                .codeHash(passwordEncoder.encode(code))
                .expiresAt(OffsetDateTime.now().plus(VALIDITY))
                .attempts(0)
                .build());

        emailSender.sendVerificationCode(user.getEmail(), user.getFullName(), code);
    }

    @Transactional
    public void resend(String rawEmail) {
        User user = userRepository.findByEmail(rawEmail.trim().toLowerCase()).orElse(null);

        // Silent success: never reveal whether an account exists.
        if (user == null || user.isEmailVerified()) {
            return;
        }

        tokenRepository.findTopByUserIdOrderByCreatedAtDesc(user.getId())
                .ifPresent(latest -> {
                    if (latest.getCreatedAt()
                            .isAfter(OffsetDateTime.now().minus(RESEND_COOLDOWN))) {
                        throw new TooManyRequestsException(
                                "Please wait a minute before requesting another code");
                    }
                });

        issueCode(user);
    }

    @Transactional
    public void verify(String rawEmail, String code) {
        User user = userRepository.findByEmail(rawEmail.trim().toLowerCase())
                .orElseThrow(() -> new InvalidOtpException(GENERIC_FAILURE));

        if (user.isEmailVerified()) {
            return; // already done — treat as success
        }

        EmailVerificationToken token = tokenRepository
                .findTopByUserIdOrderByCreatedAtDesc(user.getId())
                .orElseThrow(() -> new InvalidOtpException(GENERIC_FAILURE));

        if (token.getConsumedAt() != null
                || token.getExpiresAt().isBefore(OffsetDateTime.now())) {
            throw new InvalidOtpException(GENERIC_FAILURE);
        }

        if (token.getAttempts() >= MAX_ATTEMPTS) {
            throw new InvalidOtpException("Too many incorrect attempts. Request a new code.");
        }

        token.setAttempts(token.getAttempts() + 1);
        tokenRepository.save(token);

        if (!passwordEncoder.matches(code, token.getCodeHash())) {
            throw new InvalidOtpException(GENERIC_FAILURE);
        }

        token.setConsumedAt(OffsetDateTime.now());
        tokenRepository.save(token);

        user.setEmailVerified(true);
        userRepository.save(user);
    }
}