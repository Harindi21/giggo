package com.giggo.backend.assistant.api;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.assistant.api.dto.AskRequest;
import com.giggo.backend.assistant.api.dto.AskResponse;
import com.giggo.backend.assistant.service.AssistantService;
import com.giggo.backend.common.dto.ApiResponse;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/**
 * Knowledge Hub assistant (RAG-05): a signed-in user asks a question in plain
 * language and gets a grounded, cited answer from the retrieval-augmented ML
 * service. Authentication is required (the endpoint is not whitelisted), and the
 * call is fail-soft, so a downed ML service degrades to a friendly message.
 */
@RestController
@RequestMapping("/api/v1/assistant")
@RequiredArgsConstructor
public class AssistantController {

    private final AssistantService assistantService;

    @PostMapping("/ask")
    public ApiResponse<AskResponse> ask(@Valid @RequestBody AskRequest req) {
        return ApiResponse.ok(assistantService.ask(req.question(), req.topK()));
    }
}
