package rental_platform_backend.rent.dto;

import rental_platform_backend.rent.entity.RentChargeStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record RentChargeResponse(

        UUID id,

        UUID leaseId,

        UUID propertyId,

        String propertyTitle,

        UUID tenantUserId,

        String tenantName,

        UUID ownerId,

        String ownerName,

        Integer billingYear,

        Integer billingMonth,

        BigDecimal amount,

        LocalDate dueDate,

        RentChargeStatus status,

        LocalDateTime createdAt,

        LocalDateTime updatedAt
) {
}