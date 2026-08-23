package com.giggo.backend.knowledge.service;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.knowledge.domain.Article;
import com.giggo.backend.knowledge.repository.ArticleRepository;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

import lombok.RequiredArgsConstructor;

/**
 * "Recommended for you" Knowledge Hub guides (P9.3). Content-based: for a provider,
 * rank published articles by how well their text matches the provider's skills and
 * categories, then by popularity. Anyone without a provider profile (or with no
 * matches) just gets the most popular guides. No interaction dataset is needed, so
 * it works from day one — the collaborative variant is a Phase-2 swap.
 */
@Service
@RequiredArgsConstructor
public class ArticleRecommendationService {

    private final ArticleRepository articleRepository;
    private final ProviderProfileRepository providerRepository;

    @Value("${giggo.knowledge.recommend-limit:5}")
    private int limit = 5;

    @Transactional(readOnly = true)
    public List<Article> recommendedFor(UUID userId) {
        List<Article> published = articleRepository.findByPublishedTrueOrderByPublishedAtDesc();
        if (published.isEmpty()) {
            return List.of();
        }
        Set<String> terms = professionTerms(userId);
        Comparator<Article> ranking = Comparator
                .comparingInt((Article a) -> matchScore(a, terms)).reversed()
                .thenComparing(Comparator.comparingInt(Article::getViewCount).reversed())
                .thenComparing(Comparator.comparingInt(Article::getRatingCount).reversed());
        return published.stream().sorted(ranking).limit(limit).toList();
    }

    /** Lowercased word tokens (>=4 chars) from the provider's skills + categories. */
    private Set<String> professionTerms(UUID userId) {
        return providerRepository.findByUserId(userId)
                .map(ArticleRecommendationService::termsOf)
                .orElseGet(Set::of);
    }

    private static Set<String> termsOf(ProviderProfile profile) {
        Set<String> terms = new HashSet<>();
        for (Skill skill : profile.getSkills()) {
            addWords(terms, skill.getName());
            if (skill.getCategory() != null) {
                addWords(terms, skill.getCategory().getName());
            }
        }
        return terms;
    }

    private static void addWords(Set<String> into, String phrase) {
        if (phrase == null) {
            return;
        }
        for (String w : phrase.toLowerCase().split("[^a-z0-9]+")) {
            if (w.length() >= 4) {
                into.add(w);
            }
        }
    }

    private static int matchScore(Article a, Set<String> terms) {
        if (terms.isEmpty()) {
            return 0;
        }
        String haystack = (a.getTitle() + " " + a.getCategory() + " " + a.getExcerpt()).toLowerCase();
        return (int) terms.stream().filter(haystack::contains).count();
    }
}
