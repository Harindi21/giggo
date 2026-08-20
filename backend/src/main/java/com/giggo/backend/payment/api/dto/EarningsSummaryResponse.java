package com.giggo.backend.payment.api.dto;

import java.math.BigDecimal;

/**
 * A provider's earnings at a glance (P7.5), derived from the payments ledger and
 * the payout history — no stored balance column (see ADR-0010).
 *
 * <ul>
 *   <li>{@code available} — released funds not yet withdrawn or reserved; withdrawable now.</li>
 *   <li>{@code inEscrow} — payouts still held in escrow (HELD), not yet released.</li>
 *   <li>{@code pendingWithdrawal} — requested payouts awaiting admin processing.</li>
 *   <li>{@code withdrawn} — lifetime paid-out total.</li>
 *   <li>{@code lifetimeEarned} — lifetime released earnings.</li>
 * </ul>
 */
public record EarningsSummaryResponse(
        BigDecimal available,
        BigDecimal inEscrow,
        BigDecimal pendingWithdrawal,
        BigDecimal withdrawn,
        BigDecimal lifetimeEarned,
        String currency
) {}
