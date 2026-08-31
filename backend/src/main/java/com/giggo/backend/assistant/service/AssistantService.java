package com.giggo.backend.assistant.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.giggo.backend.assistant.api.dto.AskResponse;
import com.giggo.backend.assistant.api.dto.CitationDto;
import com.giggo.backend.assistant.service.AssistantClient.MlAskRequest;
import com.giggo.backend.assistant.service.AssistantClient.MlAskResponse;

import lombok.RequiredArgsConstructor;

/**
 * Bridges the app to the Knowledge assistant (RAG-05). Proxies the question to
 * the ML service and, if it is unavailable, returns a graceful fallback so the
 * app never sees an error. The extractive ML answerer is grounded by design, so
 * this layer stays thin: it maps wire DTOs and handles the unavailable case.
 */
@Service
@RequiredArgsConstructor
public class AssistantService {

    static final String FALLBACK_MESSAGE =
            "The assistant is unavailable right now. Please try again in a moment, "
            + "or browse the Knowledge Hub guides.";

    private final AssistantClient client;

    public AskResponse ask(String question, Integer topK) {
        return client.ask(new MlAskRequest(question, topK))
                .map(AssistantService::toResponse)
                .orElseGet(AssistantService::fallback);
    }

    private static AskResponse toResponse(MlAskResponse ml) {
        List<CitationDto> citations = ml.citations() == null ? List.of()
                : ml.citations().stream()
                        .map(c -> new CitationDto(c.slug(), c.title()))
                        .toList();
        return new AskResponse(ml.answer(), ml.grounded(), citations, ml.backend());
    }

    private static AskResponse fallback() {
        return new AskResponse(FALLBACK_MESSAGE, false, List.of(), "unavailable");
    }
}
