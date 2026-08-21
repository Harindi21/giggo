package com.giggo.backend.admin.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.admin.api.dto.AdminMetricsResponse;
import com.giggo.backend.admin.api.dto.AdminMetricsResponse.CategoryStat;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.dispute.domain.DisputeStatus;
import com.giggo.backend.dispute.repository.DisputeRepository;
import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.repository.ToolOrderRepository;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.repository.PaymentRepository;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/** Aggregates platform analytics for the admin dashboard (P11.1, P11.7). */
@Service
@RequiredArgsConstructor
public class AdminMetricsService {

    private static final Set<JobStatus> ACTIVE =
            EnumSet.of(JobStatus.REQUESTED, JobStatus.ACCEPTED, JobStatus.EN_ROUTE, JobStatus.STARTED);
    private static final Set<JobStatus> COMPLETED =
            EnumSet.of(JobStatus.COMPLETED, JobStatus.RATED, JobStatus.PAID);

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ProviderProfileRepository providerRepository;
    private final DisputeRepository disputeRepository;
    private final ToolOrderRepository toolOrderRepository;

    @Transactional(readOnly = true)
    public AdminMetricsResponse metrics() {
        BigDecimal releasedBookings = paymentRepository.sumAmountByStatus(PaymentStatus.RELEASED);
        BigDecimal revenue = paymentRepository.sumCommissionByStatus(PaymentStatus.RELEASED);
        BigDecimal toolSales = toolOrderRepository.sumTotalByStatus(OrderStatus.PAID);
        BigDecimal gmv = releasedBookings.add(toolSales);

        long totalBookings = bookingRepository.count();
        long activeJobs = bookingRepository.countByStatusIn(ACTIVE);
        long completedJobs = bookingRepository.countByStatusIn(COMPLETED);
        double conversionRate = percentage(completedJobs, totalBookings);

        long totalUsers = userRepository.count();
        long customers = userRepository.countByRole(UserRole.CUSTOMER);
        long providers = userRepository.countByRole(UserRole.PROVIDER);
        long verifiedProviders = providerRepository.countByVerifiedTrue();
        long newUsers30d = userRepository.countByCreatedAtAfter(OffsetDateTime.now().minusDays(30));

        long distinctCustomers = bookingRepository.countDistinctCustomers();
        long repeatCustomers = bookingRepository.countRepeatCustomers();
        double repeatRate = percentage(repeatCustomers, distinctCustomers);

        long openDisputes = disputeRepository.countByStatus(DisputeStatus.OPEN);
        long toolOrders = toolOrderRepository.countByStatus(OrderStatus.PAID);

        List<CategoryStat> topCategories = bookingRepository.topCategories().stream()
                .map(c -> new CategoryStat(c.getName(), c.getTotal()))
                .toList();

        return new AdminMetricsResponse(
                gmv, revenue, "LKR",
                totalBookings, activeJobs, completedJobs, conversionRate,
                totalUsers, customers, providers, verifiedProviders, newUsers30d, repeatRate,
                openDisputes, toolOrders, toolSales, topCategories);
    }

    private static double percentage(long part, long whole) {
        if (whole <= 0) {
            return 0.0;
        }
        return BigDecimal.valueOf(part * 100.0 / whole).setScale(1, RoundingMode.HALF_UP).doubleValue();
    }
}
