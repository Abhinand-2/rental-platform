package rental_platform_backend.amenity.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record AmenityResponse(
        UUID id,
        String name,
        LocalDateTime createdAt
) {
}