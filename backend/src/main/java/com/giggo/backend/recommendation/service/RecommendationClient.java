package com.giggo.backend.recommendation.service;

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
 * Calls the Python recommendation microservice (P3.4) to rank providers for a
 * customer. Fails soft: if the service is slow or down, returns empty so the
 * caller can fall back to a simple quality ranking.
 */
@Component
public class RecommendationClient {

    private static final Logger log = LoggerFactory.getLogger(RecommendationClient.class);

    private final RestClient restClient;

    public RecommendationClient(
            @Value("${giggo.ml.base-url:http://localhost:8000}") String baseUrl,
            @Value("${giggo.ml.api-key:local-dev-key}") String apiKey) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setReadTimeout(6000);
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(factory)
                .defaultHeader("X-API-Key", apiKey)
                .build();
    }

    public Optional<RecResponse> recommend(RecRequest request) {
        try {
            RecResponse res = restClient.post()
                    .uri("/api/v1/recommendations")
                    .body(request)
                    .retrieve()
                    .body(RecResponse.class);
            return Optional.ofNullable(res);
        } catch (Exception ex) {
            log.warn("Recommendation service unavailable ({}); falling back to quality ranking.",
                    ex.getMessage());
            return Optional.empty();
        }
    }

    // ---- wire DTOs (snake_case to match the Python service) ----
    public record RecRequest(
            @JsonProperty("customer_id") String customerId,
            int limit,
            Double latitude,
            Double longitude,
            List<RecProvider> candidates,
            List<RecInteraction> interactions,
            @JsonProperty("exclude_interacted") boolean excludeInteracted) {}

    public record RecProvider(
            @JsonProperty("provider_id") String providerId,
            @JsonProperty("category_ids") List<String> categoryIds,
            String district,
            @JsonProperty("avg_rating") double avgRating,
            @JsonProperty("rating_count") int ratingCount,
            @JsonProperty("jobs_completed") int jobsCompleted,
            Double latitude,
            Double longitude) {}

    public record RecInteraction(
            @JsonProperty("customer_id") String customerId,
            @JsonProperty("provider_id") String providerId,
            double weight) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record RecResponse(String strategy, List<RecResult> results) {}

    public record RecResult(
            @JsonProperty("provider_id") String providerId,
            double score,
            String reason) {}
}
