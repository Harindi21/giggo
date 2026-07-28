package com.giggo.backend.user.api.dto;

public record LoginResponse(String token, String tokenType, UserResponse user) {
    public static LoginResponse of(String token, UserResponse user) {
        return new LoginResponse(token, "Bearer", user);
    }
}