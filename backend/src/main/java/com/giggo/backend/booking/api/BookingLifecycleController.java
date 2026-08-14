package com.giggo.backend.booking.api;

import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.api.dto.CancelBookingRequest;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/**
 * Job lifecycle transitions (P4.3). Provider actions are provider-only and only
 * valid on a job assigned to that provider; cancel is open to either party.
 * Invalid transitions return 400, wrong actor returns 403.
 */
@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class BookingLifecycleController {

    private final BookingService bookingService;

    @PostMapping("/{id}/accept")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<BookingResponse> accept(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.accept(user.getId(), id));
    }

    @PostMapping("/{id}/decline")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<BookingResponse> decline(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.decline(user.getId(), id));
    }

    @PostMapping("/{id}/en-route")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<BookingResponse> enRoute(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.enRoute(user.getId(), id));
    }

    @PostMapping("/{id}/start")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<BookingResponse> start(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.start(user.getId(), id));
    }

    @PostMapping("/{id}/complete")
    @PreAuthorize("hasRole('PROVIDER')")
    public ApiResponse<BookingResponse> complete(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.complete(user.getId(), id));
    }

    @PostMapping("/{id}/cancel")
    public ApiResponse<BookingResponse> cancel(
            @AuthenticationPrincipal User user,
            @PathVariable UUID id,
            @RequestBody(required = false) CancelBookingRequest body) {
        return ApiResponse.ok(bookingService.cancel(user.getId(), id, body == null ? null : body.reason()));
    }
}
