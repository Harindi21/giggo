package com.giggo.backend.provider.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.function.Function;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

@DisplayName("FairRankingReorderer")
class FairRankingReordererTest {

    private record Item(String id, String district) {}

    private static final Function<Item, String> DISTRICT = Item::district;

    private FairRankingReorderer reorderer;

    @BeforeEach
    void setUp() {
        reorderer = new FairRankingReorderer();
        ReflectionTestUtils.setField(reorderer, "window", 3);
        ReflectionTestUtils.setField(reorderer, "minDistricts", 2);
    }

    private long distinctInTop(List<Item> list, int n) {
        return list.subList(0, Math.min(n, list.size())).stream()
                .map(Item::district).distinct().count();
    }

    @Test
    @DisplayName("promotes a regional provider into a district-concentrated top window")
    void promotesUnderRepresented() {
        List<Item> ranked = List.of(
                new Item("a", "Colombo"), new Item("b", "Colombo"), new Item("c", "Colombo"),
                new Item("d", "Kandy"), new Item("e", "Colombo"));

        List<Item> result = reorderer.reorder(ranked, DISTRICT);

        assertThat(distinctInTop(result, 3)).isGreaterThanOrEqualTo(2);
        assertThat(result.subList(0, 3)).anyMatch(i -> i.id().equals("d")); // Kandy promoted
        assertThat(result.get(0).id()).isEqualTo("a"); // top quality preserved
        assertThat(result).hasSize(5); // nothing lost
    }

    @Test
    @DisplayName("leaves an already-diverse top window untouched")
    void alreadyDiverse() {
        List<Item> ranked = List.of(
                new Item("a", "Colombo"), new Item("b", "Kandy"), new Item("c", "Galle"),
                new Item("d", "Colombo"));
        assertThat(reorderer.reorder(ranked, DISTRICT)).containsExactlyElementsOf(ranked);
    }

    @Test
    @DisplayName("cannot diversify when every provider is from one district")
    void allSameDistrict() {
        List<Item> ranked = List.of(
                new Item("a", "Colombo"), new Item("b", "Colombo"), new Item("c", "Colombo"),
                new Item("d", "Colombo"));
        assertThat(reorderer.reorder(ranked, DISTRICT)).containsExactlyElementsOf(ranked);
    }

    @Test
    @DisplayName("short lists are returned unchanged")
    void tooSmall() {
        List<Item> ranked = List.of(new Item("a", "Colombo"), new Item("b", "Colombo"));
        assertThat(reorderer.reorder(ranked, DISTRICT)).isEqualTo(ranked);
    }
}
