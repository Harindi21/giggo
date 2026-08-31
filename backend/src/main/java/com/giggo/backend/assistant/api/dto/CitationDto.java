package com.giggo.backend.assistant.api.dto;

/** A source article the assistant's answer was grounded in (RAG-05). */
public record CitationDto(String slug, String title) {}
