package com.giggo.backend;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Disabled("Full context load requires a real Postgres database; covered by Testcontainers later (P12)")
class BackendApplicationTests {

    @Test
    void contextLoads() {
    }
}