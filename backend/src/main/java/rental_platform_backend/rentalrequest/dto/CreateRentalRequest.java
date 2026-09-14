package rental_platform_backend.rentalrequest.dto;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.UUID;

public record CreateRentalRequest(

        @NotNull(message = "Property ID is required")
        UUID propertyId,

        @Size(
            max = 2000,
            message = "Message must not exceed 2000 characters"
        )
        String message,

        @NotNull(message = "Requested start date is required")
        @FutureOrPresent(message = "Requested start date cannot be in the past")
        LocalDate requestedStartDate
) {
}