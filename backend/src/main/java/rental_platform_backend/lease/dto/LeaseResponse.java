package rental_platform_backend.lease.dto;

import rental_platform_backend.lease.entity.LeaseStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record LeaseResponse(

        UUID id,

        UUID rentalRequestId,

        UUID propertyId,

        String propertyTitle,

        UUID tenantId,

        UUID tenantUserId,

        String tenantName,

        String tenantEmail,

        UUID ownerId,

        String ownerName,

        String ownerEmail,

        LocalDate startDate,

        LocalDate endDate,

        BigDecimal monthlyRent,

        BigDecimal securityDeposit,

        LeaseStatus status,

        LocalDateTime createdAt,

        LocalDateTime updatedAt
) {
}