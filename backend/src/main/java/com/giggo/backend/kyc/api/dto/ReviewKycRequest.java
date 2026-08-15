package com.giggo.backend.kyc.api.dto;

import jakarta.validation.constraints.Size;

/** Optional note when an admin approves or rejects a KYC submission. */
public record ReviewKycRequest(@Size(max = 500) String note) {}
