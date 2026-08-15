package com.giggo.backend.marketplace.api;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.marketplace.api.dto.CreateToolRequest;
import com.giggo.backend.marketplace.api.dto.ToolResponse;
import com.giggo.backend.marketplace.api.dto.UpdateToolRequest;
import com.giggo.backend.marketplace.service.ToolService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

/** Admin catalog management for the Tool Marketplace (P10.1). */
@RestController
@RequestMapping("/api/v1/admin/tools")
@RequiredArgsConstructor
public class AdminToolController {

    private final ToolService toolService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<ToolResponse> create(@Valid @RequestBody CreateToolRequest req) {
        return ApiResponse.ok(ToolResponse.from(toolService.create(req)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<ToolResponse> update(
            @PathVariable UUID id, @Valid @RequestBody UpdateToolRequest req) {
        return ApiResponse.ok(ToolResponse.from(toolService.update(id, req)));
    }
}
