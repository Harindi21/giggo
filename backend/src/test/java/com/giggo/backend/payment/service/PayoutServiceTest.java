package com.giggo.backend.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.payment.api.dto.EarningsSummaryResponse;
import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;
import com.giggo.backend.payment.repository.PayoutRepository;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("PayoutService")
class PayoutServiceTest {

    @Mock PayoutRepository payoutRepository;
    @Mock EarningsService earningsService;
    @Mock UserRepository userRepository;

    private PayoutService service;

    private final UUID providerId = UUID.randomUUID();
    private final UUID payoutId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new PayoutService(payoutRepository, earningsService, userRepository);
        lenient().when(payoutRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    private void available(String amount) {
        when(earningsService.summary(providerId)).thenReturn(new EarningsSummaryResponse(
                new BigDecimal(amount), BigDecimal.ZERO, BigDecimal.ZERO,
                BigDecimal.ZERO, new BigDecimal(amount), "LKR"));
    }

    private Payout requested() {
        return Payout.builder().id(payoutId).providerId(providerId)
                .amount(new BigDecimal("300.00")).status(PayoutStatus.REQUESTED).build();
    }

    @Test
    @DisplayName("a null amount withdraws the full available balance")
    void requestFull() {
        available("650.00");
        Payout p = service.request(providerId, null);
        assertThat(p.getAmount()).isEqualByComparingTo("650.00");
        assertThat(p.getStatus()).isEqualTo(PayoutStatus.REQUESTED);
    }

    @Test
    @DisplayName("a partial amount within balance is accepted")
    void requestPartial() {
        available("650.00");
        assertThat(service.request(providerId, new BigDecimal("400.00")).getAmount())
                .isEqualByComparingTo("400.00");
    }

    @Test
    @DisplayName("rejects an amount over the available balance")
    void requestOverBalance() {
        available("650.00");
        assertThatThrownBy(() -> service.request(providerId, new BigDecimal("700.00")))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("rejects a request with no funds available")
    void requestNoFunds() {
        available("0.00");
        assertThatThrownBy(() -> service.request(providerId, null))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("admin process marks a requested payout PAID with a reference")
    void process() {
        when(payoutRepository.findById(payoutId)).thenReturn(Optional.of(requested()));
        Payout p = service.process(payoutId, "BANK-REF-9");
        assertThat(p.getStatus()).isEqualTo(PayoutStatus.PAID);
        assertThat(p.getReference()).isEqualTo("BANK-REF-9");
        assertThat(p.getProcessedAt()).isNotNull();
    }

    @Test
    @DisplayName("admin reject marks it REJECTED with a note")
    void reject() {
        when(payoutRepository.findById(payoutId)).thenReturn(Optional.of(requested()));
        Payout p = service.reject(payoutId, "Bank details missing");
        assertThat(p.getStatus()).isEqualTo(PayoutStatus.REJECTED);
        assertThat(p.getNote()).isEqualTo("Bank details missing");
    }

    @Test
    @DisplayName("cannot process a payout that is not in REQUESTED state")
    void processNonRequested() {
        Payout paid = requested();
        paid.setStatus(PayoutStatus.PAID);
        when(payoutRepository.findById(payoutId)).thenReturn(Optional.of(paid));
        assertThatThrownBy(() -> service.process(payoutId, "REF"))
                .isInstanceOf(ForbiddenOperationException.class);
    }
}
