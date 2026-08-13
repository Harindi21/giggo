package com.giggo.backend.realtime.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

/** Optional body when granting: how long the live-sharing window lasts (minutes). */
public record GrantConsentRequest(
        @Min(1) @Max(1440) Integer durationMinutes
) {}
