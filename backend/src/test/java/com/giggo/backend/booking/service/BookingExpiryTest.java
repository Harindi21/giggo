package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.event.BookingStatusChangedEvent;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.repository.BookingStatusEventRepository;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("BookingService.expireStale (P4.4)")
class BookingExpiryTest {

    @Mock BookingRepository bookingRepository;
    @Mock BookingStatusEventRepository eventRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock SkillRepository skillRepository;
    @Mock PricingService pricingService;
    @Mock ApplicationEventPublisher events;

    private BookingService service;

    @BeforeEach
    void setUp() {
        service = new BookingService(bookingRepository, eventRepository, providerRepository,
                skillRepository, pricingService, events);
    }

    @Test
    @DisplayName("expires overdue REQUESTED bookings and records the event")
    void expiresOverdueRequests() {
        Booking stale = Booking.builder()
                .id(UUID.randomUUID())
                .status(JobStatus.REQUESTED)
                .build();
        when(bookingRepository.findByStatusAndRequestExpiresAtBefore(any(), any()))
                .thenReturn(List.of(stale));
        when(bookingRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        int expired = service.expireStale();

        assertThat(expired).isEqualTo(1);
        assertThat(stale.getStatus()).isEqualTo(JobStatus.EXPIRED);
        verify(eventRepository).save(any());
        verify(events).publishEvent(any(BookingStatusChangedEvent.class));
    }

    @Test
    @DisplayName("does nothing when there are no overdue requests")
    void noOverdueRequests() {
        when(bookingRepository.findByStatusAndRequestExpiresAtBefore(any(), any()))
                .thenReturn(List.of());

        assertThat(service.expireStale()).isZero();
    }
}
