package com.giggo.backend.booking.domain;

import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** One entry in a booking's status history. */
@Entity
@Table(name = "booking_status_events")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingStatusEvent {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "booking_id", nullable = false)
    private UUID bookingId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private JobStatus status;

    @Column(name = "at", nullable = false)
    private OffsetDateTime at;

    @PrePersist
    void onCreate() {
        if (at == null) at = OffsetDateTime.now();
    }
}
