package com.giggo.backend.payment.service;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ForbiddenOperationException;
import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.payment.api.dto.PayoutResponse;
import com.giggo.backend.payment.domain.Payout;
import com.giggo.backend.payment.domain.PayoutStatus;
import com.giggo.backend.payment.repository.PayoutRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Provider withdrawals (P7.6) + the admin processing queue (P11.9). A payout is
 * checked against the derived available balance ({@link EarningsService}); once
 * REQUESTED it reserves that amount, and an admin marks it PAID (bank transfer
 * done) or REJECTED (funds return to available).
 */
@Service
@RequiredArgsConstructor
public class PayoutService {

    private final PayoutRepository payoutRepository;
    private final EarningsService earningsService;
    private final UserRepository userRepository;

    /** Provider requests a withdrawal; a null/zero amount withdraws the full balance. */
    @Transactional
    public Payout request(UUID providerId, BigDecimal amount) {
        BigDecimal available = earningsService.summary(providerId).available();
        if (available.signum() <= 0) {
            throw new IllegalArgumentException("You have no funds available to withdraw.");
        }
        BigDecimal requested = (amount == null || amount.signum() <= 0) ? available : amount;
        if (requested.compareTo(available) > 0) {
            throw new IllegalArgumentException("Amount exceeds your available balance of " + available + ".");
        }
        return payoutRepository.save(Payout.builder()
                .providerId(providerId)
                .amount(requested)
                .currency("LKR")
                .status(PayoutStatus.REQUESTED)
                .method("BANK_TRANSFER")
                .requestedAt(OffsetDateTime.now())
                .build());
    }

    @Transactional(readOnly = true)
    public List<Payout> listMine(UUID providerId) {
        return payoutRepository.findByProviderIdOrderByCreatedAtDesc(providerId);
    }

    // ---- Admin queue (P11.9) ----

    @Transactional(readOnly = true)
    public List<PayoutResponse> adminList(PayoutStatus status) {
        List<Payout> payouts = payoutRepository.findByStatusOrderByRequestedAtAsc(status);
        Map<UUID, String> names = providerNames(payouts);
        return payouts.stream()
                .map(p -> PayoutResponse.from(p, names.get(p.getProviderId())))
                .toList();
    }

    /** Mark a requested payout paid, recording the bank-transfer reference. */
    @Transactional
    public Payout process(UUID payoutId, String reference) {
        Payout payout = requireRequested(payoutId);
        payout.setStatus(PayoutStatus.PAID);
        payout.setReference(reference);
        payout.setProcessedAt(OffsetDateTime.now());
        return payoutRepository.save(payout);
    }

    /** Decline a requested payout; its amount returns to the available balance. */
    @Transactional
    public Payout reject(UUID payoutId, String note) {
        Payout payout = requireRequested(payoutId);
        payout.setStatus(PayoutStatus.REJECTED);
        payout.setNote(note);
        payout.setProcessedAt(OffsetDateTime.now());
        return payoutRepository.save(payout);
    }

    private Payout requireRequested(UUID payoutId) {
        Payout payout = payoutRepository.findById(payoutId)
                .orElseThrow(() -> new ResourceNotFoundException("Payout not found"));
        if (payout.getStatus() != PayoutStatus.REQUESTED) {
            throw new ForbiddenOperationException(
                    "This payout is already " + payout.getStatus().name().toLowerCase() + ".");
        }
        return payout;
    }

    private Map<UUID, String> providerNames(List<Payout> payouts) {
        Set<UUID> ids = payouts.stream().map(Payout::getProviderId).collect(Collectors.toSet());
        return userRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(User::getId, User::getFullName));
    }
}
