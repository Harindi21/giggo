package com.giggo.backend.realtime.api;

import java.util.Map;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.giggo.backend.booking.event.BookingStatusChangedEvent;

import lombok.RequiredArgsConstructor;

/**
 * Broadcasts booking status changes to {@code /topic/jobs/{id}/status} so a
 * customer watching the tracking screen sees the timeline update live (P5.5).
 * Fires only after the DB transaction commits, so a rolled-back change is never
 * broadcast. Keeps the booking service free of any WebSocket knowledge.
 */
@Component
@RequiredArgsConstructor
public class StatusBroadcastListener {

    private final SimpMessagingTemplate messaging;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onStatusChanged(BookingStatusChangedEvent event) {
        String destination = "/topic/jobs/" + event.bookingId() + "/status";
        Object payload = Map.of(
                "jobId", event.bookingId().toString(),
                "status", event.status().name(),
                "at", event.at().toString());
        messaging.convertAndSend(destination, payload);
    }
}
