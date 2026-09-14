package rental_platform_backend.rent.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateRentChargeRequest(

        @NotNull
        UUID leaseId,

        @NotNull
        @Min(2000)
        Integer billingYear,

        @NotNull
        @Min(1)
        @Max(12)
        Integer billingMonth,

        @NotNull
        @DecimalMin("0.01")
        BigDecimal amount,

        @NotNull
        @FutureOrPresent
        LocalDate dueDate
) {
}