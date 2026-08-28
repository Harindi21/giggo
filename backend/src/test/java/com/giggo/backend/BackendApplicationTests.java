package com.giggo.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

/**
 * Full-context smoke test (P12). Boots the entire Spring context against a real
 * Postgres via Testcontainers, so Flyway runs every migration and Hibernate
 * validates the mapping — on every CI run. Requires Docker (present on CI and
 * local dev).
 */
@SpringBootTest
@Testcontainers
class BackendApplicationTests {

    @Container
    @ServiceConnection
    // pgvector image (Postgres 17 + the vector extension) as a compatible
    // substitute, so V33's CREATE EXTENSION vector runs under Testcontainers.
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>(
            DockerImageName.parse("pgvector/pgvector:pg17")
                    .asCompatibleSubstituteFor("postgres"));

    @Test
    void contextLoads() {
    }
}
