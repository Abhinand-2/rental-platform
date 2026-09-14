
package rental_platform_backend.lease.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateLeaseRequest(

        @NotNull(message = "Rental request ID is required")
        UUID rentalRequestId,

        @NotNull(message = "Start date is required")
        @FutureOrPresent(message = "Start date cannot be in the past")
        LocalDate startDate,

        @NotNull(message = "End date is required")
        LocalDate endDate,

        @NotNull(message = "Monthly rent is required")
        @DecimalMin(
                value = "0.01",
                message = "Monthly rent must be greater than zero"
        )
        BigDecimal monthlyRent,

        @DecimalMin(
                value = "0.00",
                message = "Security deposit cannot be negative"
        )
        BigDecimal securityDeposit
) {
}

