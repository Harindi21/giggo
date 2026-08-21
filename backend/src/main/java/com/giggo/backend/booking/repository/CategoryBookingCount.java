package com.giggo.backend.booking.repository;

/** Projection for the "top categories" analytics query (P11.7). */
public interface CategoryBookingCount {
    String getName();
    long getTotal();
}
