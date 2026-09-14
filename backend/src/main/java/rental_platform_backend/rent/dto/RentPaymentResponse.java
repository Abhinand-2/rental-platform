package rental_platform_backend.rent.dto;

import rental_platform_backend.rent.entity.RentChargeStatus;
import rental_platform_backend.rent.entity.RentPaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record RentPaymentResponse(

        UUID id,

        UUID rentChargeId,

        UUID leaseId,

        UUID propertyId,

        String propertyTitle,

        UUID tenantUserId,

        String tenantName,

        BigDecimal amount,

        LocalDateTime paidAt,

        String paymentReference,

        RentPaymentStatus status,

        RentChargeStatus chargeStatus,

        LocalDateTime createdAt
) {
}