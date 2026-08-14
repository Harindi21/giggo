package com.giggo.backend.booking.api;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.booking.api.dto.BookingResponse;
import com.giggo.backend.booking.api.dto.CreateBookingRequest;
import com.giggo.backend.booking.api.dto.StatusEventResponse;
import com.giggo.backend.booking.service.BookingService;
import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.user.domain.User;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('CUSTOMER')")
    public ApiResponse<BookingResponse> create(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateBookingRequest req) {
        return ApiResponse.ok(bookingService.create(user.getId(), req));
    }

    @GetMapping("/{id}")
    public ApiResponse<BookingResponse> get(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.getById(user.getId(), id));
    }

    /** All bookings the caller is part of (as customer or provider). */
    @GetMapping
    public ApiResponse<List<BookingResponse>> listMine(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(bookingService.listMine(user.getId()));
    }

    /** Ordered status timeline for a booking (P5.5). */
    @GetMapping("/{id}/timeline")
    public ApiResponse<List<StatusEventResponse>> timeline(
            @AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ApiResponse.ok(bookingService.timeline(user.getId(), id));
    }
}
