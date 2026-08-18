package com.giggo.backend.dispute.api;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.dispute.api.dto.DisputeResponse;
import com.giggo.backend.dispute.api.dto.RaiseDisputeRequest;
import com.giggo.backend.dispute.service.DisputeService;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Raise / view a dispute on a booking (either participant) — P4.6. */
@RestController
@RequestMapping("/api/v1/bookings/{bookingId}/dispute")
@RequiredArgsConstructor
public class DisputeController {

    private final DisputeService disputeService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<DisputeResponse> raise(
            @AuthenticationPrincipal User user,
            @PathVariable UUID bookingId,
            @Valid @RequestBody RaiseDisputeRequest req) {
        return ApiResponse.ok(DisputeResponse.from(
                disputeService.raise(user.getId(), bookingId, req.reason())));
    }

    @GetMapping
    public ApiResponse<DisputeResponse> get(
            @AuthenticationPrincipal User user, @PathVariable UUID bookingId) {
        return ApiResponse.ok(DisputeResponse.from(
                disputeService.getByBooking(user.getId(), bookingId)));
    }
}
