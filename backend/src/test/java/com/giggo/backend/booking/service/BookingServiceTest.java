package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.api.dto.CreateBookingRequest;
import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;
import com.giggo.backend.user.domain.User;

@ExtendWith(MockitoExtension.class)
@DisplayName("BookingService")
class BookingServiceTest {

    @Mock BookingRepository bookingRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock SkillRepository skillRepository;
    @Mock PricingService pricingService;

    private BookingService service;

    private final UUID customerId = UUID.randomUUID();
    private final UUID providerUserId = UUID.randomUUID();
    private final UUID providerProfileId = UUID.randomUUID();
    private final UUID skillId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new BookingService(bookingRepository, providerRepository, skillRepository, pricingService);
    }

    private ProviderProfile providerProfile() {
        return ProviderProfile.builder()
                .id(providerProfileId)
                .user(User.builder().id(providerUserId).build())
                .build();
    }

    private CreateBookingRequest request() {
        return new CreateBookingRequest(
                providerProfileId, skillId, OffsetDateTime.now().plusDays(1), new BigDecimal("2"),
                "No. 9, Rose Rd", 6.85, 79.86, "Fix leaking pipe", "Kitchen sink",
                "Ann", "0771234567", null);
    }

    @Test
    @DisplayName("creates a REQUESTED booking with a snapshotted price breakdown")
    void createsRequestedBookingWithPrice() {
        when(providerRepository.findById(providerProfileId)).thenReturn(Optional.of(providerProfile()));
        when(skillRepository.findById(skillId)).thenReturn(Optional.of(
                Skill.builder().id(skillId).name("Plumbing").build()));
        when(pricingService.calculate(any(), any(), anyDouble(), anyDouble())).thenReturn(
                new PricingBreakdownResponse(
                        new BigDecimal("500.00"), new BigDecimal("2.00"), new BigDecimal("500.00"),
                        new BigDecimal("1000.00"), new BigDecimal("5.00"), new BigDecimal("50.00"),
                        new BigDecimal("250.00"), new BigDecimal("1750.00")));
        when(bookingRepository.save(any(Booking.class))).thenAnswer(inv -> inv.getArgument(0));

        BookingResponse r = service.create(customerId, request());

        assertThat(r.status()).isEqualTo(JobStatus.REQUESTED);
        assertThat(r.customerId()).isEqualTo(customerId);
        assertThat(r.providerId()).isEqualTo(providerUserId); // resolved to the provider's user id
        assertThat(r.skillName()).isEqualTo("Plumbing");
        assertThat(r.totalPrice()).isEqualByComparingTo("1750.00");
        assertThat(r.requestExpiresAt()).isNotNull(); // defaulted
    }

    @Test
    @DisplayName("rejects booking yourself")
    void rejectsSelfBooking() {
        when(providerRepository.findById(providerProfileId)).thenReturn(Optional.of(providerProfile()));
        assertThatThrownBy(() -> service.create(providerUserId, request()))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("unknown provider -> 404")
    void unknownProvider() {
        when(providerRepository.findById(providerProfileId)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.create(customerId, request()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("get by id is blocked for non-participants")
    void getByIdForbiddenForOutsider() {
        Booking booking = Booking.builder()
                .id(UUID.randomUUID()).customerId(customerId).providerId(providerUserId)
                .skillId(skillId).status(JobStatus.REQUESTED).build();
        when(bookingRepository.findById(booking.getId())).thenReturn(Optional.of(booking));

        assertThatThrownBy(() -> service.getById(UUID.randomUUID(), booking.getId()))
                .isInstanceOf(ForbiddenOperationException.class);
    }
}
