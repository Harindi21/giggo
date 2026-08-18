package com.giggo.backend.dispute.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RaiseDisputeRequest(@NotBlank @Size(max = 1000) String reason) {}
