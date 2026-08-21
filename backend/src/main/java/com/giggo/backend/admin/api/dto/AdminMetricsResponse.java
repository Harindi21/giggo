package com.giggo.backend.admin.api.dto;

import java.math.BigDecimal;
import java.util.List;

/** Platform analytics for the admin dashboard (P11.1, P11.7). */
public record AdminMetricsResponse(
        BigDecimal gmv,               // released bookings + paid tool orders
        BigDecimal platformRevenue,   // commission on released bookings
        String currency,
        long totalBookings,
        long activeJobs,
        long completedJobs,
        double conversionRate,        // completed / total bookings, %
        long totalUsers,
        long customers,
        long providers,
        long verifiedProviders,
        long newUsers30d,
        double repeatCustomerRate,    // customers with >1 booking / customers with any, %
        long openDisputes,
        long toolOrders,
        BigDecimal toolSales,
        List<CategoryStat> topCategories
) {
    public record CategoryStat(String name, long bookings) {}
}
