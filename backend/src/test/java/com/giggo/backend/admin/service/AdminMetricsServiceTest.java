package com.giggo.backend.admin.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.admin.api.dto.AdminMetricsResponse;
import com.giggo.backend.booking.domain.JobStatus;
import com.giggo.backend.booking.repository.BookingRepository;
import com.giggo.backend.booking.repository.CategoryBookingCount;
import com.giggo.backend.dispute.domain.DisputeStatus;
import com.giggo.backend.dispute.repository.DisputeRepository;
import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.repository.ToolOrderRepository;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.repository.PaymentRepository;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("AdminMetricsService")
class AdminMetricsServiceTest {

    @Mock PaymentRepository paymentRepository;
    @Mock BookingRepository bookingRepository;
    @Mock UserRepository userRepository;
    @Mock ProviderProfileRepository providerRepository;
    @Mock DisputeRepository disputeRepository;
    @Mock ToolOrderRepository toolOrderRepository;

    private AdminMetricsService service;

    @BeforeEach
    void setUp() {
        service = new AdminMetricsService(paymentRepository, bookingRepository, userRepository,
                providerRepository, disputeRepository, toolOrderRepository);
    }

    private CategoryBookingCount cat(String name, long total) {
        CategoryBookingCount c = mock(CategoryBookingCount.class);
        when(c.getName()).thenReturn(name);
        when(c.getTotal()).thenReturn(total);
        return c;
    }

    @Test
    @DisplayName("aggregates GMV, conversion, repeat rate and top categories")
    void aggregates() {
        when(paymentRepository.sumAmountByStatus(PaymentStatus.RELEASED)).thenReturn(new BigDecimal("10000"));
        when(paymentRepository.sumCommissionByStatus(PaymentStatus.RELEASED)).thenReturn(new BigDecimal("1000"));
        when(toolOrderRepository.sumTotalByStatus(OrderStatus.PAID)).thenReturn(new BigDecimal("2000"));

        when(bookingRepository.count()).thenReturn(10L);
        when(bookingRepository.countByStatusIn(argThat(s -> s != null && s.contains(JobStatus.REQUESTED)))).thenReturn(3L);
        when(bookingRepository.countByStatusIn(argThat(s -> s != null && s.contains(JobStatus.COMPLETED)))).thenReturn(5L);
        when(bookingRepository.countDistinctCustomers()).thenReturn(4L);
        when(bookingRepository.countRepeatCustomers()).thenReturn(1L);
        CategoryBookingCount plumbing = cat("Plumbing", 6);
        CategoryBookingCount electrical = cat("Electrical", 4);
        when(bookingRepository.topCategories()).thenReturn(List.of(plumbing, electrical));

        when(userRepository.count()).thenReturn(8L);
        when(userRepository.countByRole(UserRole.CUSTOMER)).thenReturn(5L);
        when(userRepository.countByRole(UserRole.PROVIDER)).thenReturn(3L);
        when(userRepository.countByCreatedAtAfter(any())).thenReturn(4L);
        when(providerRepository.countByVerifiedTrue()).thenReturn(2L);
        when(disputeRepository.countByStatus(DisputeStatus.OPEN)).thenReturn(1L);
        when(toolOrderRepository.countByStatus(OrderStatus.PAID)).thenReturn(2L);

        AdminMetricsResponse m = service.metrics();

        assertThat(m.gmv()).isEqualByComparingTo("12000");        // 10000 + 2000
        assertThat(m.platformRevenue()).isEqualByComparingTo("1000");
        assertThat(m.toolSales()).isEqualByComparingTo("2000");
        assertThat(m.conversionRate()).isEqualTo(50.0);           // 5/10
        assertThat(m.repeatCustomerRate()).isEqualTo(25.0);       // 1/4
        assertThat(m.activeJobs()).isEqualTo(3);
        assertThat(m.verifiedProviders()).isEqualTo(2);
        assertThat(m.newUsers30d()).isEqualTo(4);
        assertThat(m.openDisputes()).isEqualTo(1);
        assertThat(m.topCategories()).hasSize(2);
        assertThat(m.topCategories().get(0).name()).isEqualTo("Plumbing");
        assertThat(m.topCategories().get(0).bookings()).isEqualTo(6);
    }

    @Test
    @DisplayName("no data -> zero rates, not division errors")
    void emptyPlatform() {
        when(paymentRepository.sumAmountByStatus(PaymentStatus.RELEASED)).thenReturn(BigDecimal.ZERO);
        when(paymentRepository.sumCommissionByStatus(PaymentStatus.RELEASED)).thenReturn(BigDecimal.ZERO);
        when(toolOrderRepository.sumTotalByStatus(OrderStatus.PAID)).thenReturn(BigDecimal.ZERO);
        when(bookingRepository.count()).thenReturn(0L);
        when(bookingRepository.countDistinctCustomers()).thenReturn(0L);
        when(bookingRepository.topCategories()).thenReturn(List.of());

        AdminMetricsResponse m = service.metrics();

        assertThat(m.conversionRate()).isEqualTo(0.0);
        assertThat(m.repeatCustomerRate()).isEqualTo(0.0);
        assertThat(m.gmv()).isEqualByComparingTo("0");
        assertThat(m.topCategories()).isEmpty();
    }
}
