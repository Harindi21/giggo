package com.giggo.backend.marketplace.api;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giggo.backend.common.dto.ApiResponse;
import com.giggo.backend.marketplace.api.dto.ToolResponse;
import com.giggo.backend.marketplace.service.ToolService;

import lombok.RequiredArgsConstructor;

/** Public Tool Marketplace reads (P10.1). */
@RestController
@RequestMapping("/api/v1/tools")
@RequiredArgsConstructor
public class ToolController {

    private final ToolService toolService;

    @GetMapping
    public ApiResponse<List<ToolResponse>> list(
            @RequestParam(required = false) String category) {
        return ApiResponse.ok(toolService.listAvailable(category).stream()
                .map(ToolResponse::from)
                .toList());
    }

    @GetMapping("/{slug}")
    public ApiResponse<ToolResponse> get(@PathVariable String slug) {
        return ApiResponse.ok(ToolResponse.from(toolService.getBySlug(slug)));
    }
}
