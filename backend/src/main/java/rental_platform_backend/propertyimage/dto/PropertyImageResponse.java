package rental_platform_backend.propertyimage.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record PropertyImageResponse(
        UUID id,
        UUID propertyId,
        String imageUrl,
        Integer displayOrder,
        boolean primary,
        LocalDateTime createdAt
) {
}