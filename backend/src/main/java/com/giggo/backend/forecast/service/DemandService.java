package com.giggo.backend.forecast.service;

import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.forecast.api.dto.CategoryDemandResponse;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;

import lombok.RequiredArgsConstructor;

/**
 * Demand forecasting for providers (AI #4). Builds a weekly booking-count series
 * per service category and projects the next week via the ML forecast service
 * (falling back to a naive in-process projection). A provider sees the outlook
 * for their own categories; ordering surfaces the busiest.
 */
@Service
@RequiredArgsConstructor
public class DemandService {

    private static final int WEEKS = 8;

    private final BookingRepository bookingRepository;
    private final SkillRepository skillRepository;
    private final ProviderProfileRepository providerRepository;
    private final ForecastClient forecastClient;

    @Transactional(readOnly = true)
    public List<CategoryDemandResponse> demandForProvider(UUID userId) {
        OffsetDateTime now = OffsetDateTime.now();
        List<Booking> recent = bookingRepository.findByCreatedAtAfter(now.minusWeeks(WEEKS));

        Map<UUID, String> skillCategory = skillRepository.findAll().stream()
                .filter(s -> s.getCategory() != null)
                .collect(Collectors.toMap(Skill::getId, s -> s.getCategory().getName()));

        Map<String, int[]> counts = new HashMap<>();
        for (Booking b : recent) {
            String category = skillCategory.get(b.getSkillId());
            if (category == null || b.getCreatedAt() == null) {
                continue;
            }
            long weeksAgo = ChronoUnit.WEEKS.between(b.getCreatedAt(), now);
            if (weeksAgo < 0 || weeksAgo >= WEEKS) {
                continue;
            }
            int idx = (int) (WEEKS - 1 - weeksAgo); // oldest week at index 0
            counts.computeIfAbsent(category, k -> new int[WEEKS])[idx]++;
        }

        Set<String> categories = providerCategories(userId);
        if (categories.isEmpty()) {
            categories = new TreeSet<>(counts.keySet());
        }

        List<CategoryDemandResponse> out = new ArrayList<>();
        for (String category : categories) {
            int[] weekly = counts.getOrDefault(category, new int[WEEKS]);
            List<Integer> series = Arrays.stream(weekly).boxed().toList();
            out.add(project(category, weekly, series));
        }
        out.sort(Comparator.comparingInt(CategoryDemandResponse::forecastNextWeek).reversed());
        return out;
    }

    private CategoryDemandResponse project(String category, int[] weekly, List<Integer> series) {
        var forecast = forecastClient.forecast(series, 1);
        if (forecast.isPresent() && forecast.get().forecast() != null
                && !forecast.get().forecast().isEmpty()) {
            int next = (int) Math.round(forecast.get().forecast().get(0));
            return new CategoryDemandResponse(category, series, Math.max(0, next), forecast.get().trend());
        }
        return new CategoryDemandResponse(category, series, naiveNext(weekly), naiveTrend(weekly));
    }

    private Set<String> providerCategories(UUID userId) {
        return providerRepository.findByUserId(userId)
                .map(p -> p.getSkills().stream()
                        .map(s -> s.getCategory() != null ? s.getCategory().getName() : null)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toCollection(TreeSet::new)))
                .map(s -> (Set<String>) s)
                .orElseGet(TreeSet::new);
    }

    private static int naiveNext(int[] weekly) {
        int k = Math.min(3, weekly.length);
        if (k == 0) {
            return 0;
        }
        int sum = 0;
        for (int i = weekly.length - k; i < weekly.length; i++) {
            sum += weekly[i];
        }
        return Math.round((float) sum / k);
    }

    private static String naiveTrend(int[] weekly) {
        int n = weekly.length;
        if (n < 2) {
            return "steady";
        }
        int half = n / 2;
        double first = 0;
        double second = 0;
        for (int i = 0; i < half; i++) {
            first += weekly[i];
        }
        for (int i = half; i < n; i++) {
            second += weekly[i];
        }
        first /= Math.max(1, half);
        second /= Math.max(1, n - half);
        double diff = second - first;
        double threshold = 0.1 * (first == 0 ? 1 : first);
        if (diff > threshold) {
            return "rising";
        }
        if (diff < -threshold) {
            return "falling";
        }
        return "steady";
    }
}
