package com.giggo.backend.notification.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.giggo.backend.booking.domain.Booking;
import com.giggo.backend.booking.event.BookingStatusChangedEvent;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.notification.service.BookingNotificationPlanner;
import com.giggo.backend.notification.service.NotificationService;

import lombok.RequiredArgsConstructor;

/**
 * Turns booking status changes into notifications (P8.1). Fires only after the
 * transaction commits, and fails soft so a notification problem never affects
 * the booking flow. Keeps the booking service free of notification concerns.
 */
@Component
@RequiredArgsConstructor
public class BookingNotificationListener {

    private static final Logger log = LoggerFactory.getLogger(BookingNotificationListener.class);

    private final NotificationService notificationService;
    private final BookingRepository bookingRepository;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onStatusChanged(BookingStatusChangedEvent event) {
        try {
            Booking booking = bookingRepository.findById(event.bookingId()).orElse(null);
            if (booking == null) {
                return;
            }
            BookingNotificationPlanner.plan(booking, event.status()).ifPresent(plan ->
                    notificationService.notify(
                            plan.recipientId(), plan.type(), plan.title(), plan.body(), booking.getId()));
        } catch (Exception ex) {
            log.warn("Could not create notification for booking {} ({}): {}",
                    event.bookingId(), event.status(), ex.getMessage());
        }
    }
}
