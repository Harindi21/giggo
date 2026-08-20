package com.giggo.backend.payment.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.payment.api.dto.EarningsSummaryResponse;
import com.giggo.backend.payment.domain.Payment;
import com.giggo.backend.payment.domain.PaymentStatus;
import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;
import com.giggo.backend.payment.repository.PaymentRepository;
import com.giggo.backend.payment.repository.PayoutRepository;

import lombok.RequiredArgsConstructor;

/**
 * A provider's earnings as a <b>derived read-model</b> over the payments ledger
 * and payout history (P7.5, ADR-0010) — there is no stored balance column, so the
 * numbers can never drift from the source records.
 */
@Service
@RequiredArgsConstructor
public class EarningsService {

    private final PaymentRepository paymentRepository;
    private final PayoutRepository payoutRepository;

    @Transactional(readOnly = true)
    public EarningsSummaryResponse summary(UUID providerId) {
        List<Payment> payments = paymentRepository.findByProviderIdOrderByCreatedAtDesc(providerId);
        BigDecimal lifetimeEarned = payoutSum(payments, PaymentStatus.RELEASED);
        BigDecimal inEscrow = payoutSum(payments, PaymentStatus.HELD);

        List<Payout> payouts = payoutRepository.findByProviderIdOrderByCreatedAtDesc(providerId);
        BigDecimal withdrawn = payoutTotal(payouts, PayoutStatus.PAID);
        BigDecimal pending = payoutTotal(payouts, PayoutStatus.REQUESTED);

        BigDecimal available = lifetimeEarned.subtract(withdrawn).subtract(pending).max(BigDecimal.ZERO);
        return new EarningsSummaryResponse(
                available, inEscrow, pending, withdrawn, lifetimeEarned, "LKR");
    }

    /** A provider's payment history, newest first. */
    @Transactional(readOnly = true)
    public List<Payment> history(UUID providerId) {
        return paymentRepository.findByProviderIdOrderByCreatedAtDesc(providerId);
    }

    private static BigDecimal payoutSum(List<Payment> payments, PaymentStatus status) {
        return payments.stream()
                .filter(p -> p.getStatus() == status)
                .map(Payment::getProviderPayout)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private static BigDecimal payoutTotal(List<Payout> payouts, PayoutStatus status) {
        return payouts.stream()
                .filter(p -> p.getStatus() == status)
                .map(Payout::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
