package com.giggo.backend.recommendation.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.provider.api.dto.ProviderCardResponse;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.recommendation.service.RecommendationClient.RecInteraction;
import com.giggo.backend.recommendation.service.RecommendationClient.RecProvider;
import com.giggo.backend.recommendation.service.RecommendationClient.RecRequest;
import com.giggo.backend.recommendation.service.RecommendationClient.RecResponse;

import lombok.RequiredArgsConstructor;

/**
 * Personalised provider recommendations (P3.4). Gathers candidate providers and
 * the interaction matrix, asks the ML service to rank them, and maps the result
 * back to provider cards. Falls back to a quality ranking if the ML service is
 * unavailable or has nothing to go on.
 */
@Service
@RequiredArgsConstructor
public class RecommendationService {

    private final ProviderProfileRepository profileRepository;
    private final BookingRepository bookingRepository;
    private final RecommendationClient client;

    @Transactional(readOnly = true)
    public List<ProviderCardResponse> recommendFor(UUID customerId, int limit, Double lat, Double lng) {
        // Active providers, already ordered by rating quality (also the fallback order).
        List<ProviderProfile> active = profileRepository.search(null, null, null, null);
        if (active.isEmpty()) {
            return List.of();
        }

        Map<UUID, ProviderProfile> byProfileId = active.stream()
                .collect(Collectors.toMap(ProviderProfile::getId, Function.identity(), (a, b) -> a, LinkedHashMap::new));
        // provider user id -> profile id (bookings reference the provider's user id).
        Map<UUID, UUID> userToProfile = active.stream()
                .collect(Collectors.toMap(p -> p.getUser().getId(), ProviderProfile::getId, (a, b) -> a));

        List<RecProvider> candidates = active.stream().map(this::toFeature).toList();
        List<RecInteraction> interactions = buildInteractions(userToProfile);

        RecRequest request = new RecRequest(
                customerId.toString(), limit, lat, lng, candidates, interactions, true);

        List<ProviderProfile> ordered = client.recommend(request)
                .map(RecResponse::results)
                .filter(results -> !results.isEmpty())
                .map(results -> results.stream()
                        .map(r -> byProfileId.get(parseId(r.providerId())))
                        .filter(Objects::nonNull)
                        .toList())
                .filter(list -> !list.isEmpty())
                .orElseGet(() -> active.stream().limit(limit).toList());

        return ordered.stream().map(ProviderCardResponse::from).toList();
    }

    private List<RecInteraction> buildInteractions(Map<UUID, UUID> userToProfile) {
        List<RecInteraction> interactions = new ArrayList<>();
        for (Booking b : bookingRepository.findAll()) {
            double weight = weight(b.getStatus());
            if (weight <= 0) {
                continue;
            }
            UUID profileId = userToProfile.get(b.getProviderId());
            if (profileId == null) {
                continue; // provider no longer active / not discoverable
            }
            interactions.add(new RecInteraction(
                    b.getCustomerId().toString(), profileId.toString(), weight));
        }
        return interactions;
    }

    private RecProvider toFeature(ProviderProfile p) {
        List<String> categoryIds = p.getSkills().stream()
                .map(s -> s.getCategory().getId().toString())
                .distinct()
                .toList();
        return new RecProvider(
                p.getId().toString(),
                categoryIds,
                p.getDistrict(),
                p.getAvgRating() == null ? 0.0 : p.getAvgRating().doubleValue(),
                p.getRatingCount(),
                p.getJobsCompleted(),
                p.getLatitude(),
                p.getLongitude());
    }

    /** Interaction strength by lifecycle stage; cancelled/declined/expired count for nothing. */
    private static double weight(JobStatus status) {
        return switch (status) {
            case COMPLETED, RATED, PAID -> 3.0;
            case STARTED, EN_ROUTE, ACCEPTED -> 2.0;
            case REQUESTED -> 1.0;
            case CANCELLED, DECLINED, EXPIRED -> 0.0;
        };
    }

    private static UUID parseId(String id) {
        try {
            return UUID.fromString(id);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
