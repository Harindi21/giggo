package com.giggo.backend.notification.service;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.notification.api.dto.NotificationPreferenceResponse;
import com.giggo.backend.notification.domain.NotificationCategory;
import com.giggo.backend.notification.domain.NotificationPreference;
import com.giggo.backend.notification.repository.NotificationPreferenceRepository;

import lombok.RequiredArgsConstructor;

/**
 * Per-category push preferences (P8.5). Opt-out model: a category with no stored
 * row is enabled by default. Only push delivery is gated — in-app inbox entries
 * are always kept.
 */
@Service
@RequiredArgsConstructor
public class NotificationPreferenceService {

    private final NotificationPreferenceRepository repository;

    /** Effective preference for every category (stored value, or the enabled default). */
    @Transactional(readOnly = true)
    public List<NotificationPreferenceResponse> list(UUID userId) {
        Map<NotificationCategory, Boolean> stored = repository.findByUserId(userId).stream()
                .collect(Collectors.toMap(NotificationPreference::getCategory,
                        NotificationPreference::isPushEnabled));
        return Arrays.stream(NotificationCategory.values())
                .map(c -> new NotificationPreferenceResponse(c, stored.getOrDefault(c, true)))
                .toList();
    }

    /** Whether push is on for a category (default true when unset). */
    @Transactional(readOnly = true)
    public boolean isPushEnabled(UUID userId, NotificationCategory category) {
        return repository.findByUserIdAndCategory(userId, category)
                .map(NotificationPreference::isPushEnabled)
                .orElse(true);
    }

    @Transactional
    public NotificationPreferenceResponse set(UUID userId, NotificationCategory category, boolean enabled) {
        NotificationPreference pref = repository.findByUserIdAndCategory(userId, category)
                .orElseGet(() -> NotificationPreference.builder().userId(userId).category(category).build());
        pref.setPushEnabled(enabled);
        NotificationPreference saved = repository.save(pref);
        return new NotificationPreferenceResponse(saved.getCategory(), saved.isPushEnabled());
    }
}
