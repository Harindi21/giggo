package com.giggo.backend.provider.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Fairness post-processor (thesis: Amer-Yahia et al.). Marketplaces self-reinforce —
 * the same few high-review providers stay visible while newer/regional ones never
 * surface. After the quality sort, if the top window is too concentrated in a few
 * districts, this promotes under-represented-district providers into the window by
 * swapping them with over-represented entries. It only touches the tail of the window,
 * so strong quality signals near the top are preserved.
 */
@Component
public class FairRankingReorderer {

    @Value("${giggo.ranking.fair-window:10}")
    private int window;
    @Value("${giggo.ranking.fair-min-districts:3}")
    private int minDistricts;

    public <T> List<T> reorder(List<T> ranked, Function<T, String> districtOf) {
        if (ranked.size() <= 2) {
            return ranked;
        }
        List<T> result = new ArrayList<>(ranked);
        int win = Math.min(window, result.size());

        while (true) {
            Map<String, Integer> counts = windowCounts(result, win, districtOf);
            if (counts.size() >= minDistricts) {
                break; // already diverse enough
            }
            int candidate = firstBelowWindowFromNewDistrict(result, win, counts, districtOf);
            if (candidate < 0) {
                break; // nothing under-represented to promote
            }
            int overIndex = lastWindowIndexOverRepresented(result, win, counts, districtOf);
            if (overIndex < 0) {
                break; // window already all-unique but still short — can't add without dropping one
            }
            // swap: under-represented provider moves into the window, over-represented one drops below
            T promoted = result.get(candidate);
            result.set(candidate, result.get(overIndex));
            result.set(overIndex, promoted);
        }
        return result;
    }

    private <T> Map<String, Integer> windowCounts(List<T> list, int win, Function<T, String> districtOf) {
        Map<String, Integer> counts = new HashMap<>();
        for (int i = 0; i < win; i++) {
            String d = normalize(districtOf.apply(list.get(i)));
            if (d != null) {
                counts.merge(d, 1, Integer::sum);
            }
        }
        return counts;
    }

    private <T> int firstBelowWindowFromNewDistrict(
            List<T> list, int win, Map<String, Integer> windowDistricts, Function<T, String> districtOf) {
        for (int i = win; i < list.size(); i++) {
            String d = normalize(districtOf.apply(list.get(i)));
            if (d != null && !windowDistricts.containsKey(d)) {
                return i;
            }
        }
        return -1;
    }

    private <T> int lastWindowIndexOverRepresented(
            List<T> list, int win, Map<String, Integer> counts, Function<T, String> districtOf) {
        for (int i = win - 1; i >= 0; i--) {
            String d = normalize(districtOf.apply(list.get(i)));
            if (d != null && counts.getOrDefault(d, 0) > 1) {
                return i;
            }
        }
        return -1;
    }

    private static String normalize(String district) {
        return (district == null || district.isBlank()) ? null : district.trim().toLowerCase();
    }
}
