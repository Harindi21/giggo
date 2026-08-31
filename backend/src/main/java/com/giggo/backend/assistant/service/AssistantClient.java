package com.giggo.backend.assistant.service;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Calls the Python Knowledge-assistant microservice (RAG-05) over HTTP. Fails
 * soft: if the service is slow or down, returns empty so the caller can show a
 * graceful "assistant unavailable" message instead of an error.
 */
@Component
public class AssistantClient {

    private static final Logger log = LoggerFactory.getLogger(AssistantClient.class);

    private final RestClient restClient;

    public AssistantClient(
            @Value("${giggo.ml.base-url:http://localhost:8000}") String baseUrl,
            @Value("${giggo.ml.api-key:local-dev-key}") String apiKey) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setReadTimeout(8000);
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(factory)
                .defaultHeader("X-API-Key", apiKey)
                .build();
    }

    public Optional<MlAskResponse> ask(MlAskRequest request) {
        try {
            MlAskResponse res = restClient.post()
                    .uri("/api/v1/assistant/ask")
                    .body(request)
                    .retrieve()
                    .body(MlAskResponse.class);
            return Optional.ofNullable(res);
        } catch (Exception ex) {
            log.warn("Assistant service unavailable ({}); returning a graceful fallback.", ex.getMessage());
            return Optional.empty();
        }
    }

    // ---- wire DTOs (snake_case to match the Python service) ----
    public record MlAskRequest(String question, @JsonProperty("top_k") Integer topK) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record MlAskResponse(
            String answer,
            boolean grounded,
            List<MlCitation> citations,
            @JsonProperty("retrieved_chunks") int retrievedChunks,
            String backend) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record MlCitation(String slug, String title) {}
}
