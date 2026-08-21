package com.giggo.backend.notification.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.notification.api.dto.NotificationPreferenceResponse;
import com.giggo.backend.notification.domain.NotificationCategory;
import com.giggo.backend.notification.domain.NotificationPreference;
import com.giggo.backend.notification.repository.NotificationPreferenceRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("NotificationPreferenceService")
class NotificationPreferenceServiceTest {

    @Mock NotificationPreferenceRepository repository;

    private NotificationPreferenceService service;

    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new NotificationPreferenceService(repository);
    }

    @Test
    @DisplayName("list defaults every category to enabled, overriding stored rows")
    void listWithDefaults() {
        when(repository.findByUserId(userId)).thenReturn(List.of(
                NotificationPreference.builder().userId(userId)
                        .category(NotificationCategory.PAYMENTS).pushEnabled(false).build()));

        List<NotificationPreferenceResponse> prefs = service.list(userId);

        assertThat(prefs).hasSize(NotificationCategory.values().length);
        assertThat(prefs).anySatisfy(p -> {
            assertThat(p.category()).isEqualTo(NotificationCategory.PAYMENTS);
            assertThat(p.pushEnabled()).isFalse();
        });
        assertThat(prefs).filteredOn(p -> p.category() == NotificationCategory.BOOKINGS)
                .singleElement().satisfies(p -> assertThat(p.pushEnabled()).isTrue());
    }

    @Test
    @DisplayName("isPushEnabled is true when unset, false when muted")
    void isPushEnabled() {
        when(repository.findByUserIdAndCategory(userId, NotificationCategory.REVIEWS))
                .thenReturn(Optional.empty());
        assertThat(service.isPushEnabled(userId, NotificationCategory.REVIEWS)).isTrue();

        when(repository.findByUserIdAndCategory(userId, NotificationCategory.BOOKINGS))
                .thenReturn(Optional.of(NotificationPreference.builder()
                        .userId(userId).category(NotificationCategory.BOOKINGS).pushEnabled(false).build()));
        assertThat(service.isPushEnabled(userId, NotificationCategory.BOOKINGS)).isFalse();
    }

    @Test
    @DisplayName("set upserts the preference")
    void setUpserts() {
        when(repository.findByUserIdAndCategory(userId, NotificationCategory.PAYMENTS))
                .thenReturn(Optional.empty());
        when(repository.save(any())).thenAnswer(i -> i.getArgument(0));

        NotificationPreferenceResponse out = service.set(userId, NotificationCategory.PAYMENTS, false);

        assertThat(out.category()).isEqualTo(NotificationCategory.PAYMENTS);
        assertThat(out.pushEnabled()).isFalse();
    }
}
