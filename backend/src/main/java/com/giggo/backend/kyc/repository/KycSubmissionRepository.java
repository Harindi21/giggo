package com.giggo.backend.kyc.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.kyc.domain.KycStatus;
import com.giggo.backend.kyc.domain.KycSubmission;

public interface KycSubmissionRepository extends JpaRepository<KycSubmission, UUID> {
    Optional<KycSubmission> findByProviderUserId(UUID providerUserId);
    List<KycSubmission> findByStatusOrderBySubmittedAtAsc(KycStatus status);
}
