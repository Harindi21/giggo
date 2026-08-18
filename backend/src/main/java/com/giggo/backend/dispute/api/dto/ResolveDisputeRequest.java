package com.giggo.backend.dispute.api.dto;

import jakarta.validation.constraints.Size;

/** Admin resolution: refund the escrow, or dismiss; with an optional note. */
public record ResolveDisputeRequest(boolean refund, @Size(max = 1000) String note) {}
