package com.giggo.backend.provider.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giggo.backend.provider.domain.ProviderProfile;

public interface ProviderProfileRepository extends JpaRepository<ProviderProfile, UUID> {
    Optional<ProviderProfile> findByUserId(UUID userId);
    boolean existsByUserId(UUID userId);

    /** Verified providers, for admin analytics (P11.1). */
    long countByVerifiedTrue();

    /**
     * Provider search with optional filters. Any filter left null is ignored.
     * Results are pre-sorted by rating quality; a fairness pass (Phase C) may
     * re-order the top slice afterwards.
     */
    @Query("""
            SELECT DISTINCT p FROM ProviderProfile p
            JOIN p.user u
            LEFT JOIN p.skills s
            WHERE u.deletedAt IS NULL AND u.active = true
              AND (:skillId IS NULL OR s.id = :skillId)
              AND (:categoryId IS NULL OR s.category.id = :categoryId)
              AND (:district IS NULL OR LOWER(p.district) = LOWER(CAST(:district AS string)))
              AND (:q IS NULL OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:q AS string), '%')))
            ORDER BY p.avgRating DESC, p.ratingCount DESC, p.jobsCompleted DESC
            """)
    List<ProviderProfile> search(@Param("categoryId") UUID categoryId,
                                 @Param("skillId") UUID skillId,
                                 @Param("district") String district,
                                 @Param("q") String q);
}
