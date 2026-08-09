package com.giggo.backend.booking.api;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.booking.api.dto.PricingBreakdownResponse;
import com.giggo.backend.booking.api.dto.QuoteRequest;
import com.giggo.backend.booking.service.PricingService;
import com.giggo.backend.common.dto.ApiResponse;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Price estimate before booking (any authenticated user). */
@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class PricingController {

    private final PricingService pricingService;

    @PostMapping("/quote")
    public ApiResponse<PricingBreakdownResponse> quote(@Valid @RequestBody QuoteRequest req) {
        return ApiResponse.ok(pricingService.quote(req));
    }
}
