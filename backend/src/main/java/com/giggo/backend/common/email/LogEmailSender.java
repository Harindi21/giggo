package com.giggo.backend.common.email;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@ConditionalOnProperty(
        name = "giggo.email.provider",
        havingValue = "log",
        matchIfMissing = true
)
public class LogEmailSender implements EmailSender {

    @Override
    public void sendVerificationCode(String toEmail, String toName, String code) {
        log.warn("""
                
                ┌──────────────────────────────────────────┐
                │  DEV EMAIL — NOT SENT                     │
                │  To   : {}
                │  Code : {}   (valid for 10 minutes)
                └──────────────────────────────────────────┘
                """, toEmail, code);
    }
}