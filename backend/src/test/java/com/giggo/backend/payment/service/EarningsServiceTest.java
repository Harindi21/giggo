package com.giggo.backend.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.payment.api.dto.EarningsSummaryResponse;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;
import com.giggo.backend.payment.repository.PaymentRepository;
import com.giggo.backend.payment.repository.PayoutRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("EarningsService")
class EarningsServiceTest {

    @Mock PaymentRepository paymentRepository;
    @Mock PayoutRepository payoutRepository;

    private EarningsService service;

    private final UUID providerId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new EarningsService(paymentRepository, payoutRepository);
    }

    private Payment payment(PaymentStatus status, String payout) {
        return Payment.builder()
                .id(UUID.randomUUID()).bookingId(UUID.randomUUID())
                .providerId(providerId).customerId(UUID.randomUUID())
                .amount(new BigDecimal("1000.00")).providerPayout(new BigDecimal(payout))
                .status(status).gateway("stub").build();
    }

    private Payout payout(PayoutStatus status, String amount) {
        return Payout.builder().id(UUID.randomUUID()).providerId(providerId)
                .amount(new BigDecimal(amount)).status(status).build();
    }

    @Test
    @DisplayName("derives available = released − withdrawn − pending, and surfaces escrow")
    void derivesBalances() {
        when(paymentRepository.findByProviderIdOrderByCreatedAtDesc(providerId)).thenReturn(List.of(
                payment(PaymentStatus.RELEASED, "900.00"),
                payment(PaymentStatus.RELEASED, "450.00"),
                payment(PaymentStatus.HELD, "270.00")));      // still in escrow
        when(payoutRepository.findByProviderIdOrderByCreatedAtDesc(providerId)).thenReturn(List.of(
                payout(PayoutStatus.PAID, "500.00"),
                payout(PayoutStatus.REQUESTED, "200.00"),
                payout(PayoutStatus.REJECTED, "999.00")));    // rejected → ignored

        EarningsSummaryResponse s = service.summary(providerId);

        assertThat(s.lifetimeEarned()).isEqualByComparingTo("1350.00"); // 900 + 450
        assertThat(s.inEscrow()).isEqualByComparingTo("270.00");
        assertThat(s.withdrawn()).isEqualByComparingTo("500.00");
        assertThat(s.pendingWithdrawal()).isEqualByComparingTo("200.00");
        assertThat(s.available()).isEqualByComparingTo("650.00");       // 1350 − 500 − 200
        assertThat(s.currency()).isEqualTo("LKR");
    }

    @Test
    @DisplayName("available never goes negative")
    void neverNegative() {
        when(paymentRepository.findByProviderIdOrderByCreatedAtDesc(providerId)).thenReturn(List.of(
                payment(PaymentStatus.RELEASED, "100.00")));
        when(payoutRepository.findByProviderIdOrderByCreatedAtDesc(providerId)).thenReturn(List.of(
                payout(PayoutStatus.PAID, "100.00")));

        assertThat(service.summary(providerId).available()).isEqualByComparingTo("0.00");
    }
}
