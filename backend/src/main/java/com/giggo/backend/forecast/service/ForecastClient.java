package com.giggo.backend.forecast.service;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Calls the Python demand-forecasting microservice (AI #4). Fails soft: if the
 * service is slow or down, returns empty so the caller can fall back to a naive
 * in-process projection.
 */
@Component
public class ForecastClient {

    private static final Logger log = LoggerFactory.getLogger(ForecastClient.class);

    private final RestClient restClient;

    public ForecastClient(
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

    public Optional<ForecastResult> forecast(List<Integer> series, int horizon) {
        try {
            ForecastResult res = restClient.post()
                    .uri("/api/v1/forecast")
                    .body(new ForecastRequest(series, horizon))
                    .retrieve()
                    .body(ForecastResult.class);
            return Optional.ofNullable(res);
        } catch (Exception ex) {
            log.warn("Forecast service unavailable ({}); using naive projection.", ex.getMessage());
            return Optional.empty();
        }
    }

    public record ForecastRequest(List<Integer> series, int horizon) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ForecastResult(List<Double> forecast, String trend, String method) {}
}
