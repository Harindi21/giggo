package com.giggo.backend.realtime.api.dto;

/** Inbound GPS ping from the provider's app (sent over the WebSocket). */
public record LocationUpdate(
        Double latitude,
        Double longitude,
        Double headingDegrees,
        Double speedKmh,
        Double accuracyMeters
) {}
