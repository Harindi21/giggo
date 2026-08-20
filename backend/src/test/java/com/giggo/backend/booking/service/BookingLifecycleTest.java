package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import com.giggo.backend.provider.service.AvailabilityService;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.BookingStatusEvent;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.repository.BookingStatusEventRepository;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("BookingService – job state machine")
class BookingLifecycleTest {

    @Mock BookingRepository bookingRepository;
    @Mock BookingStatusEventRepository eventRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock SkillRepository skillRepository;
    @Mock PricingService pricingService;
    @Mock AvailabilityService availabilityService;
    @Mock ApplicationEventPublisher events;

    private BookingService service;

    private final UUID providerId = UUID.randomUUID();
    private final UUID customerId = UUID.randomUUID();
    private final UUID id = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new BookingService(bookingRepository, eventRepository, providerRepository,
                skillRepository, pricingService, availabilityService, events);
        lenient().when(bookingRepository.save(any(Booking.class))).thenAnswer(inv -> inv.getArgument(0));
    }

    private Booking booking(JobStatus status) {
        return Booking.builder()
                .id(id).customerId(customerId).providerId(providerId)
                .skillId(UUID.randomUUID()).status(status).build();
    }

    @Test
    @DisplayName("provider accepts a REQUESTED job -> ACCEPTED with timestamp")
    void acceptFromRequested() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.REQUESTED)));
        var r = service.accept(providerId, id);
        assertThat(r.status()).isEqualTo(JobStatus.ACCEPTED);
        assertThat(r.acceptedAt()).isNotNull();
    }

    @Test
    @DisplayName("a different provider cannot act on the job")
    void wrongProviderForbidden() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.REQUESTED)));
        assertThatThrownBy(() -> service.accept(UUID.randomUUID(), id))
                .isInstanceOf(ForbiddenOperationException.class);
    }

    @Test
    @DisplayName("illegal transition is rejected (complete from REQUESTED)")
    void illegalTransition() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.REQUESTED)));
        assertThatThrownBy(() -> service.complete(providerId, id))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("full happy path REQUESTED -> ACCEPTED -> EN_ROUTE -> STARTED -> COMPLETED")
    void happyPath() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.REQUESTED)));
        assertThat(service.accept(providerId, id).status()).isEqualTo(JobStatus.ACCEPTED);
        assertThat(service.enRoute(providerId, id).status()).isEqualTo(JobStatus.EN_ROUTE);
        assertThat(service.start(providerId, id).status()).isEqualTo(JobStatus.STARTED);
        var done = service.complete(providerId, id);
        assertThat(done.status()).isEqualTo(JobStatus.COMPLETED);
        assertThat(done.startedAt()).isNotNull();
        assertThat(done.completedAt()).isNotNull();
    }

    @Test
    @DisplayName("customer can cancel before work starts")
    void cancelByCustomer() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.REQUESTED)));
        var r = service.cancel(customerId, id, "changed my mind");
        assertThat(r.status()).isEqualTo(JobStatus.CANCELLED);
        assertThat(r.cancelledBy()).isEqualTo(customerId);
        assertThat(r.cancelReason()).isEqualTo("changed my mind");
    }

    @Test
    @DisplayName("cannot cancel once work has STARTED")
    void cannotCancelAfterStarted() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.STARTED)));
        assertThatThrownBy(() -> service.cancel(customerId, id, null))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("timeline returns ordered events for a participant; outsider forbidden")
    void timeline() {
        when(bookingRepository.findById(id)).thenReturn(Optional.of(booking(JobStatus.COMPLETED)));
        when(eventRepository.findByBookingIdOrderByAtAsc(id)).thenReturn(List.of(
                BookingStatusEvent.builder().bookingId(id).status(JobStatus.REQUESTED)
                        .at(OffsetDateTime.now().minusMinutes(5)).build(),
                BookingStatusEvent.builder().bookingId(id).status(JobStatus.COMPLETED)
                        .at(OffsetDateTime.now()).build()));

        var events = service.timeline(customerId, id);
        assertThat(events).hasSize(2);
        assertThat(events.get(0).status()).isEqualTo(JobStatus.REQUESTED);

        assertThatThrownBy(() -> service.timeline(UUID.randomUUID(), id))
                .isInstanceOf(ForbiddenOperationException.class);
    }
}
