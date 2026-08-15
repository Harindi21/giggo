package com.giggo.backend.booking.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

/**
 * Periodically expires unanswered booking requests past their deadline (P4.4).
 * Interval is configurable via {@code giggo.booking.expiry-sweep-ms}.
 */
@Component
@RequiredArgsConstructor
public class BookingExpiryScheduler {

    private static final Logger log = LoggerFactory.getLogger(BookingExpiryScheduler.class);

    private final BookingService bookingService;

    @Scheduled(fixedDelayString = "${giggo.booking.expiry-sweep-ms:60000}")
    public void sweep() {
        try {
            int expired = bookingService.expireStale();
            if (expired > 0) {
                log.info("Expired {} unanswered booking request(s).", expired);
            }
        } catch (Exception ex) {
            log.warn("Booking expiry sweep failed: {}", ex.getMessage());
        }
    }
}
