package com.giggo.backend.provider.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.api.dto.ProviderCardResponse;
import com.giggo.backend.provider.api.dto.ProviderDetailResponse;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.repository.ProviderProfileRepository;

import lombok.RequiredArgsConstructor;

/** Customer-facing provider discovery (search + detail). */
@Service
@RequiredArgsConstructor
public class ProviderDiscoveryService {

    private final ProviderProfileRepository profileRepository;

    @Transactional(readOnly = true)
    public List<ProviderCardResponse> search(UUID categoryId, UUID skillId, String district, String q) {
        String qn = (q == null || q.isBlank()) ? null : q.trim();
        String dn = (district == null || district.isBlank()) ? null : district.trim();
        return profileRepository.search(categoryId, skillId, dn, qn).stream()
                .map(ProviderCardResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProviderDetailResponse getById(UUID id) {
        ProviderProfile p = profileRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Provider not found"));
        return ProviderDetailResponse.from(p);
    }
}
