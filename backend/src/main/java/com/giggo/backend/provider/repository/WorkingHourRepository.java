package com.giggo.backend.provider.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.provider.domain.WorkingHour;

public interface WorkingHourRepository extends JpaRepository<WorkingHour, UUID> {

    List<WorkingHour> findByProviderIdOrderByDayOfWeekAsc(UUID providerId);

    @Transactional
    void deleteByProviderId(UUID providerId);
}
