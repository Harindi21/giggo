package com.giggo.backend.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "giggo.jwt")
public record JwtProperties(String secret, long expirationMinutes, long refreshExpirationDays) {}