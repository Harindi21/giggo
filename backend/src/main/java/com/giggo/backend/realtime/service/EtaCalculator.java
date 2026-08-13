package com.giggo.backend.realtime.service;

/**
 * Estimated time of arrival between two points.
 * Default impl is straight-line (Haversine) + a speed assumption; a Google Maps
 * Distance Matrix impl (real road routing) can replace it without touching callers.
 */
public interface EtaCalculator {

    EtaResult estimate(double fromLat, double fromLng, double toLat, double toLng, Double currentSpeedKmh);

    record EtaResult(double distanceKm, int etaMinutes, double speedKmhUsed) {}
}
