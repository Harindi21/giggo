package com.giggo.backend.marketplace.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** A tool / equipment listing in the marketplace (P10.1). */
@Entity
@Table(name = "tools")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Tool {

    @Id @GeneratedValue
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "slug", nullable = false, unique = true, length = 160)
    private String slug;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "category", nullable = false, length = 60)
    private String category;

    @Column(name = "brand", length = 120)
    private String brand;

    @Column(name = "description", nullable = false, length = 1000)
    private String description;

    @Column(name = "price", nullable = false)
    private BigDecimal price;

    @Column(name = "currency", nullable = false, length = 3)
    @Builder.Default
    private String currency = "LKR";

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "available", nullable = false)
    @Builder.Default
    private boolean available = true;

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
    void onUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
