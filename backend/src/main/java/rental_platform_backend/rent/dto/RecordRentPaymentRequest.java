package rental_platform_backend.rent.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.UUID;

public record RecordRentPaymentRequest(

        @NotNull(message = "Rent charge ID is required")
        UUID rentChargeId,

        @NotNull(message = "Payment amount is required")
        @DecimalMin(
                value = "0.01",
                message = "Payment amount must be greater than zero"
        )
        BigDecimal amount,

        @Size(
                max = 100,
                message = "Payment reference must not exceed 100 characters"
        )
        String paymentReference
) {
}