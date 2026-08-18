package com.giggo.backend.integration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;
import com.giggo.backend.user.service.JwtService;

/**
 * End-to-end happy path over real HTTP against a Postgres Testcontainer:
 * book -> accept -> en route -> start -> complete -> review -> pay (escrow
 * held -> released) -> booking PAID. Users are seeded verified and JWTs are
 * minted directly, so the flow doesn't depend on the email-OTP path.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
@DisplayName("Booking → payment → review end-to-end")
class BookingFlowIntegrationTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:17");

    @Autowired MockMvc mvc;
    @Autowired JwtService jwtService;
    @Autowired UserRepository userRepository;
    @Autowired ProviderProfileRepository providerRepository;
    @Autowired SkillRepository skillRepository;

    private final ObjectMapper json = new ObjectMapper();

    private String customerToken;
    private String providerToken;
    private UUID providerProfileId;
    private UUID skillId;

    @BeforeEach
    void setUp() {
        User customer = userRepository.save(user("cust", UserRole.CUSTOMER));
        User provider = userRepository.save(user("prov", UserRole.PROVIDER));
        customerToken = jwtService.generateToken(customer);
        providerToken = jwtService.generateToken(provider);

        Skill skill = skillRepository.findAll().get(0); // seeded by V9 taxonomy
        skillId = skill.getId();

        ProviderProfile profile = providerRepository.save(ProviderProfile.builder()
                .user(provider)
                .available(true)
                .yearsExperience(3)
                .district("Colombo")
                .latitude(6.9271)
                .longitude(79.8612)
                .basePrice(new BigDecimal("1500"))
                .hourlyRate(new BigDecimal("800"))
                .skills(Set.of(skill))
                .build());
        providerProfileId = profile.getId();
    }

    private User user(String tag, UserRole role) {
        String uniq = UUID.randomUUID().toString().substring(0, 8);
        return User.builder()
                .email(tag + "-" + uniq + "@giggo.test")
                .phone("07" + uniq)
                .passwordHash("x")
                .fullName(tag.equals("cust") ? "Test Customer" : "Test Provider")
                .role(role)
                .active(true)
                .emailVerified(true)
                .build();
    }

    @Test
    @DisplayName("drives the full lifecycle and settles the booking as PAID")
    void fullFlow() throws Exception {
        // 1) Customer books.
        String createBody = json.writeValueAsString(Map.of(
                "providerId", providerProfileId.toString(),
                "skillId", skillId.toString(),
                "scheduledAt", OffsetDateTime.now().plusDays(1).toString(),
                "estimatedHours", 2,
                "latitude", 6.90,
                "longitude", 79.86,
                "taskTitle", "Fix kitchen sink",
                "contactName", "Test Customer",
                "contactPhone", "0771234567"));
        MvcResult created = mvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON).content(createBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.status").value("REQUESTED"))
                .andReturn();
        UUID bookingId = idOf(created);

        // 2) Provider works the job through the state machine.
        provider(bookingId, "accept", "ACCEPTED");
        provider(bookingId, "en-route", "EN_ROUTE");
        provider(bookingId, "start", "STARTED");
        provider(bookingId, "complete", "COMPLETED");

        // 3) Customer reviews (COMPLETED -> RATED). ML service is down in tests,
        //    so sentiment is null but the review still saves (fails soft).
        mvc.perform(post("/api/v1/bookings/" + bookingId + "/reviews")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json.writeValueAsString(Map.of("stars", 5, "body", "great work"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.stars").value(5));

        // 4) Customer pays: initiate -> confirm (escrow HELD) -> release.
        MvcResult initiated = mvc.perform(post("/api/v1/bookings/" + bookingId + "/payment")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.status").value("PENDING"))
                .andExpect(jsonPath("$.data.checkoutUrl").isNotEmpty())
                .andReturn();
        UUID paymentId = idOf(initiated);

        mvc.perform(post("/api/v1/payments/" + paymentId + "/confirm")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("HELD"));

        mvc.perform(post("/api/v1/payments/" + paymentId + "/release")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("RELEASED"))
                .andExpect(jsonPath("$.data.providerPayout").value(org.hamcrest.Matchers.notNullValue()));

        // 5) Booking is settled and the timeline captured every step.
        mvc.perform(get("/api/v1/bookings/" + bookingId)
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("PAID"));

        MvcResult timeline = mvc.perform(get("/api/v1/bookings/" + bookingId + "/timeline")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andReturn();
        List<String> statuses = json.readTree(timeline.getResponse().getContentAsString())
                .get("data").findValuesAsText("status");
        assertThat(statuses).contains(
                "REQUESTED", "ACCEPTED", "EN_ROUTE", "STARTED", "COMPLETED", "RATED", "PAID");
    }

    @Test
    @DisplayName("a customer cannot drive provider-only transitions")
    void customerCannotAccept() throws Exception {
        String createBody = json.writeValueAsString(Map.of(
                "providerId", providerProfileId.toString(),
                "skillId", skillId.toString(),
                "scheduledAt", OffsetDateTime.now().plusDays(1).toString(),
                "estimatedHours", 1));
        UUID bookingId = idOf(mvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON).content(createBody))
                .andExpect(status().isCreated()).andReturn());

        // Customer token on a provider-only endpoint -> 403.
        mvc.perform(post("/api/v1/bookings/" + bookingId + "/accept")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
    }

    private void provider(UUID bookingId, String action, String expectedStatus) throws Exception {
        mvc.perform(post("/api/v1/bookings/" + bookingId + "/" + action)
                        .header("Authorization", "Bearer " + providerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value(expectedStatus));
    }

    private UUID idOf(MvcResult result) throws Exception {
        return UUID.fromString(json.readTree(result.getResponse().getContentAsString())
                .at("/data/id").asText());
    }
}
