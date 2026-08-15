package com.giggo.backend.notification.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.notification.service.BookingNotificationPlanner.NotificationPlan;

@DisplayName("BookingNotificationPlanner")
class BookingNotificationPlannerTest {

    private final UUID customer = UUID.randomUUID();
    private final UUID provider = UUID.randomUUID();

    private Booking booking() {
        return Booking.builder().customerId(customer).providerId(provider).build();
    }

    @Test
    @DisplayName("notifies the provider of a new request")
    void requestedNotifiesProvider() {
        NotificationPlan plan = BookingNotificationPlanner.plan(booking(), JobStatus.REQUESTED).orElseThrow();
        assertThat(plan.recipientId()).isEqualTo(provider);
        assertThat(plan.type()).isEqualTo("BOOKING_REQUESTED");
    }

    @Test
    @DisplayName("notifies the customer when accepted")
    void acceptedNotifiesCustomer() {
        NotificationPlan plan = BookingNotificationPlanner.plan(booking(), JobStatus.ACCEPTED).orElseThrow();
        assertThat(plan.recipientId()).isEqualTo(customer);
        assertThat(plan.type()).isEqualTo("BOOKING_ACCEPTED");
    }

    @Test
    @DisplayName("notifies the provider when escrow is released (PAID)")
    void paidNotifiesProvider() {
        NotificationPlan plan = BookingNotificationPlanner.plan(booking(), JobStatus.PAID).orElseThrow();
        assertThat(plan.recipientId()).isEqualTo(provider);
        assertThat(plan.type()).isEqualTo("PAYMENT_RELEASED");
    }

    @Test
    @DisplayName("on cancel, notifies the party who did not cancel")
    void cancelNotifiesOtherParty() {
        Booking b = booking();
        b.setCancelledBy(customer); // customer cancelled -> provider is told
        NotificationPlan plan = BookingNotificationPlanner.plan(b, JobStatus.CANCELLED).orElseThrow();
        assertThat(plan.recipientId()).isEqualTo(provider);
        assertThat(plan.type()).isEqualTo("BOOKING_CANCELLED");
    }
}
