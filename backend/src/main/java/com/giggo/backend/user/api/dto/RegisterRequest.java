package com.giggo.backend.user.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(

        @NotBlank @Email @Size(max = 255)
        String email,

        @NotBlank
        @Pattern(
                regexp = "^(?:\\+94|0)7\\d{8}$",
                message = "Phone must be a Sri Lankan mobile number, e.g. 0712345678 or +94712345678"
        )
        String phone,

        @NotBlank @Size(min = 8, max = 72, message = "Password must be 8–72 characters")
        String password,

        @NotBlank @Size(max = 255)
        String fullName,

        String role
) {}