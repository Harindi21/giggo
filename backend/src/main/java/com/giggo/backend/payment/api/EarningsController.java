package com.giggo.backend.payment.api;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.payment.api.dto.EarningsSummaryResponse;
import com.giggo.backend.payment.api.dto.PaymentResponse;
import com.giggo.backend.payment.api.dto.PayoutResponse;
import com.giggo.backend.payment.api.dto.RequestPayoutRequest;
import com.giggo.backend.payment.service.EarningsService;
import com.giggo.backend.payment.service.PayoutService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Provider earnings + withdrawals (P7.5, P7.6). */
@RestController
@RequestMapping("/api/v1/provider/earnings")
@RequiredArgsConstructor
public class EarningsController {

    private final EarningsService earningsService;
    private final PayoutService payoutService;

    @GetMapping
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<EarningsSummaryResponse> summary(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(earningsService.summary(user.getId()));
    }

    @GetMapping("/history")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<List<PaymentResponse>> history(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(earningsService.history(user.getId()).stream()
                .map(PaymentResponse::from)
                .toList());
    }

    @GetMapping("/payouts")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<List<PayoutResponse>> myPayouts(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(payoutService.listMine(user.getId()).stream()
                .map(PayoutResponse::from)
                .toList());
    }

    @PostMapping("/payouts")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<PayoutResponse> requestPayout(
            @AuthenticationPrincipal User user, @Valid @RequestBody RequestPayoutRequest req) {
        return ApiResponse.ok(PayoutResponse.from(payoutService.request(user.getId(), req.amount())));
    }
}
