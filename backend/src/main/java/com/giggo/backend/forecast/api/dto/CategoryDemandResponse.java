package com.giggo.backend.forecast.api.dto;

import java.util.List;

/** Demand outlook for one service category (AI #4). */
public record CategoryDemandResponse(
        String category,
        List<Integer> weeklyCounts,   // oldest → newest, one per recent week
        int forecastNextWeek,
        String trend                  // rising | falling | steady
) {}
