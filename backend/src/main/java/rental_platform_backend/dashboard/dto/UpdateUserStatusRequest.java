package rental_platform_backend.dashboard.dto;

import jakarta.validation.constraints.NotNull;
import rental_platform_backend.user.entity.UserStatus;

public record UpdateUserStatusRequest(

        @NotNull
        UserStatus status

) {
}