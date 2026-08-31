package com.giggo.backend.assistant.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.assistant.api.dto.AskResponse;
import com.giggo.backend.assistant.service.AssistantClient.MlAskResponse;
import com.giggo.backend.assistant.service.AssistantClient.MlCitation;

@ExtendWith(MockitoExtension.class)
@DisplayName("AssistantService")
class AssistantServiceTest {

    @Mock AssistantClient client;

    private AssistantService service;

    @BeforeEach
    void setUp() {
        service = new AssistantService(client);
    }

    @Test
    @DisplayName("maps a grounded ML answer with its citations")
    void mapsGroundedAnswer() {
        when(client.ask(any())).thenReturn(Optional.of(new MlAskResponse(
                "Escrow holds the payment until the job is done.",
                true,
                List.of(new MlCitation("how-escrow-works", "How escrow works")),
                2,
                "local-extractive")));

        AskResponse out = service.ask("how does escrow work?", null);

        assertThat(out.grounded()).isTrue();
        assertThat(out.answer()).contains("Escrow");
        assertThat(out.backend()).isEqualTo("local-extractive");
        assertThat(out.citations()).singleElement()
                .satisfies(c -> {
                    assertThat(c.slug()).isEqualTo("how-escrow-works");
                    assertThat(c.title()).isEqualTo("How escrow works");
                });
    }

    @Test
    @DisplayName("returns a graceful fallback when the ML service is unavailable")
    void fallsBackWhenUnavailable() {
        when(client.ask(any())).thenReturn(Optional.empty());

        AskResponse out = service.ask("how does escrow work?", null);

        assertThat(out.grounded()).isFalse();
        assertThat(out.backend()).isEqualTo("unavailable");
        assertThat(out.answer()).isEqualTo(AssistantService.FALLBACK_MESSAGE);
        assertThat(out.citations()).isEmpty();
    }

    @Test
    @DisplayName("tolerates a null citation list from the ML service")
    void toleratesNullCitations() {
        when(client.ask(any())).thenReturn(Optional.of(new MlAskResponse(
                "I could not find that in the Knowledge Hub.", false, null, 0, "local-extractive")));

        AskResponse out = service.ask("what is the capital of France?", null);

        assertThat(out.grounded()).isFalse();
        assertThat(out.citations()).isEmpty();
    }
}
