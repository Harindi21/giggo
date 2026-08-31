package com.giggo.backend.assistant.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** A customer question for the Knowledge Hub assistant (RAG-05). */
public record AskRequest(
        @NotBlank @Size(max = 1000) String question,
        @Min(1) @Max(20) Integer topK) {}
