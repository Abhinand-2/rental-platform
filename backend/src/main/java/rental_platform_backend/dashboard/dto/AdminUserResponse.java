package rental_platform_backend.dashboard.dto;

import rental_platform_backend.user.entity.Role;
import rental_platform_backend.user.entity.UserStatus;

import java.time.LocalDateTime;
import java.util.UUID;

public record AdminUserResponse(
        UUID id,
        String firstName,
        String lastName,
        String fullName,
        String email,
        String phone,
        Role role,
        UserStatus status,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}