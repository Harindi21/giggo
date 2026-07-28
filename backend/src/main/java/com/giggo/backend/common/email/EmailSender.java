package com.giggo.backend.common.email;

public interface EmailSender {
    void sendVerificationCode(String toEmail, String toName, String code);
}