package com.giggo.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

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
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:17");

    @Test
    void contextLoads() {
    }
}
