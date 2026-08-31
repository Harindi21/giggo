package com.giggo.backend.assistant.api.dto;

import java.util.List;

/** The assistant's grounded answer with its citations (RAG-05). */
public record AskResponse(
        String answer,
        boolean grounded,
        List<CitationDto> citations,
        String backend) {}
