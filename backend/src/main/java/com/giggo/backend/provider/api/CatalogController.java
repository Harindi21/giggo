package com.giggo.backend.provider.api;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.provider.api.dto.CategoryResponse;
import com.giggo.backend.provider.api.dto.CreateCategoryRequest;
import com.giggo.backend.provider.api.dto.CreateSkillRequest;
import com.giggo.backend.provider.api.dto.SkillResponse;
import com.giggo.backend.provider.service.CatalogService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/catalog")
@RequiredArgsConstructor
public class CatalogController {

    private final CatalogService catalogService;

    // ---- Public browse ----
    @GetMapping("/categories")
    public ApiResponse<List<CategoryResponse>> categories() {
        return ApiResponse.ok(catalogService.listCategories());
    }

    @GetMapping("/categories/{categoryId}/skills")
    public ApiResponse<List<SkillResponse>> skills(@PathVariable UUID categoryId) {
        return ApiResponse.ok(catalogService.listSkillsByCategory(categoryId));
    }

    // ---- Admin only ----
    @PostMapping("/categories")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<CategoryResponse> createCategory(@Valid @RequestBody CreateCategoryRequest req) {
        return ApiResponse.ok(catalogService.createCategory(req));
    }

    @PostMapping("/skills")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<SkillResponse> createSkill(@Valid @RequestBody CreateSkillRequest req) {
        return ApiResponse.ok(catalogService.createSkill(req));
    }
}