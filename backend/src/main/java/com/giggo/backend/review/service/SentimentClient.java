package com.giggo.backend.review.service;

import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Calls the Python NLP microservice (P6.2) over HTTP to score review text.
 * Fails soft: if the service is slow or down, returns empty so a review can still
 * be submitted (sentiment stays null and is backfilled later).
 */
@Component
public class SentimentClient {

    private static final Logger log = LoggerFactory.getLogger(SentimentClient.class);

    private final RestClient restClient;

    public SentimentClient(
            @Value("${giggo.ml.base-url:http://localhost:8000}") String baseUrl,
            @Value("${giggo.ml.api-key:local-dev-key}") String apiKey) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setReadTimeout(4000);
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(factory)
                .defaultHeader("X-API-Key", apiKey)
                .build();
    }

    public Optional<SentimentResult> analyze(String text) {
        if (text == null || text.isBlank()) {
            return Optional.empty();
        }
        try {
            SentimentResult result = restClient.post()
                    .uri("/api/v1/sentiment")
                    .body(Map.of("text", text))
                    .retrieve()
                    .body(SentimentResult.class);
            return Optional.ofNullable(result);
        } catch (Exception ex) {
            log.warn("Sentiment service unavailable ({}); storing review without sentiment.", ex.getMessage());
            return Optional.empty();
        }
    }

    public record SentimentResult(
            String label,
            double score,
            @JsonProperty("star_rating") int starRating,
            double confidence,
            String emotion,
            String language) {}
}
