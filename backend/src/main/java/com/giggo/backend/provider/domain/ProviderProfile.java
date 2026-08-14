package com.giggo.backend.provider.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import com.giggo.backend.user.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "provider_profiles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProviderProfile {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "bio", length = 1000)
    private String bio;

    @Column(name = "years_experience", nullable = false)
    private int yearsExperience;

    @Column(name = "available", nullable = false)
    private boolean available;

    /** Short public tagline, e.g. "Experienced Plumber". */
    @Column(name = "headline", length = 150)
    private String headline;

    @Column(name = "district", length = 100)
    private String district;

    @Column(name = "address_line", length = 255)
    private String addressLine;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    /** Fixed call-out fee for a job (LKR). */
    @Column(name = "base_price", nullable = false)
    @Builder.Default
    private BigDecimal basePrice = BigDecimal.ZERO;

    /** Charge per estimated working hour (LKR). */
    @Column(name = "hourly_rate", nullable = false)
    @Builder.Default
    private BigDecimal hourlyRate = BigDecimal.ZERO;

    /** Bayesian composite rating (0 = no reviews). Denormalised for list rendering. */
    @Column(name = "avg_rating", nullable = false)
    @Builder.Default
    private BigDecimal avgRating = BigDecimal.ZERO;

    @Column(name = "rating_count", nullable = false)
    @Builder.Default
    private int ratingCount = 0;

    /** Raw sum of enhanced ratings; the Bayesian avg_rating is derived from this (P6.3). */
    @Column(name = "rating_sum", nullable = false)
    @Builder.Default
    private BigDecimal ratingSum = BigDecimal.ZERO;

    @Column(name = "jobs_completed", nullable = false)
    @Builder.Default
    private int jobsCompleted = 0;

    /** True once KYC is approved (P2). */
    @Column(name = "verified", nullable = false)
    @Builder.Default
    private boolean verified = false;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "provider_skills",
            joinColumns = @JoinColumn(name = "provider_profile_id"),
            inverseJoinColumns = @JoinColumn(name = "skill_id")
    )
    @Builder.Default
    private Set<Skill> skills = new HashSet<>();

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void onCreate() {
        OffsetDateTime now = OffsetDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() { updatedAt = OffsetDateTime.now(); }
}