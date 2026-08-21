package com.giggo.backend.marketplace.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giggo.backend.marketplace.domain.OrderStatus;
import com.giggo.backend.marketplace.domain.ToolOrder;

public interface ToolOrderRepository extends JpaRepository<ToolOrder, UUID> {
    List<ToolOrder> findByCustomerIdOrderByCreatedAtDesc(UUID customerId);

    // ---- Admin analytics (P11.1) ----
    long countByStatus(OrderStatus status);

    @Query("SELECT COALESCE(SUM(o.totalPrice), 0) FROM ToolOrder o WHERE o.status = :status")
    BigDecimal sumTotalByStatus(@Param("status") OrderStatus status);
}
