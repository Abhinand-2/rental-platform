
package rental_platform_backend.tenant.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record TenantResponse(
    UUID id,
    UUID userId,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}

