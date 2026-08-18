package com.giggo.backend.marketplace.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giggo.backend.marketplace.domain.ToolOrder;

public interface ToolOrderRepository extends JpaRepository<ToolOrder, UUID> {
    List<ToolOrder> findByCustomerIdOrderByCreatedAtDesc(UUID customerId);
}
