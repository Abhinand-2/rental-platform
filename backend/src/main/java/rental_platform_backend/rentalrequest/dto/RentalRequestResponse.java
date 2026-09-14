package rental_platform_backend.rentalrequest.dto;

import rental_platform_backend.rentalrequest.entity.RentalRequestStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record RentalRequestResponse(

        UUID id,

        UUID propertyId,

        String propertyTitle,

        UUID applicantUserId,

        String applicantName,

        String applicantEmail,

        String message,

        LocalDate requestedStartDate,

        RentalRequestStatus status,

        boolean leaseExists,

        LocalDateTime createdAt,

        LocalDateTime updatedAt
) {
}