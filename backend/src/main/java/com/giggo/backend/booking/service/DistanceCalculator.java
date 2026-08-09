package com.giggo.backend.booking.service;

/**
 * Distance between two geographic points, in kilometres.
 * The default implementation is straight-line (Haversine); a Google Maps
 * Distance Matrix implementation can replace it in P5 without touching callers.
 */
public interface DistanceCalculator {
    double distanceKm(double lat1, double lon1, double lat2, double lon2);
}
