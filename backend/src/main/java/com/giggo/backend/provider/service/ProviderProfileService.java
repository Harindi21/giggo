package com.giggo.backend.provider.service;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.provider.api.dto.ProviderProfileResponse;
import com.giggo.backend.provider.api.dto.UpdateProviderProfileRequest;
import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProviderProfileService {

    private final ProviderProfileRepository profileRepository;
    private final SkillRepository skillRepository;
    private final UserRepository userRepository;

    /** Gets the caller's profile, creating an empty one on first access. */
    @Transactional
    public ProviderProfileResponse getOrCreateMyProfile(UUID userId) {
        ProviderProfile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> createEmptyProfile(userId));
        return ProviderProfileResponse.from(profile);
    }

    @Transactional
    public ProviderProfileResponse updateMyProfile(UUID userId, UpdateProviderProfileRequest req) {
        ProviderProfile profile = profileRepository.findByUserId(userId)
                .orElseGet(() -> createEmptyProfile(userId));

        profile.setBio(req.bio());
        profile.setYearsExperience(req.yearsExperience());

        if (req.skillIds() != null) {
            Set<Skill> skills = new HashSet<>(skillRepository.findAllById(req.skillIds()));
            if (skills.size() != req.skillIds().size()) {
                throw new ResourceNotFoundException("One or more selected skills do not exist");
            }
            profile.setSkills(skills);
        }
        return ProviderProfileResponse.from(profileRepository.save(profile));
    }

    private ProviderProfile createEmptyProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        ProviderProfile profile = ProviderProfile.builder()
                .user(user)
                .yearsExperience(0)
                .available(true)
                .build();
        return profileRepository.save(profile);
    }
}