package com.giggo.backend.marketplace.api;

import java.util.List;
import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.marketplace.api.dto.ToolResponse;
import com.giggo.backend.marketplace.service.WishlistService;
import com.giggo.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

/** Tool wishlist / save-for-later (P10.3). */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class WishlistController {

    private final WishlistService wishlistService;

    @GetMapping("/wishlist")
    public ApiResponse<List<ToolResponse>> myWishlist(@AuthenticationPrincipal User user) {
        return ApiResponse.ok(wishlistService.list(user.getId()));
    }

    @PostMapping("/tools/{toolId}/wishlist")
    public ApiResponse<Void> add(@AuthenticationPrincipal User user, @PathVariable UUID toolId) {
        wishlistService.add(user.getId(), toolId);
        return ApiResponse.ok(null);
    }

    @DeleteMapping("/tools/{toolId}/wishlist")
    public ApiResponse<Void> remove(@AuthenticationPrincipal User user, @PathVariable UUID toolId) {
        wishlistService.remove(user.getId(), toolId);
        return ApiResponse.ok(null);
    }
}
