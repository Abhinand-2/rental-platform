package rental_platform_backend.propertyimage.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreatePropertyImageRequest(

        @NotBlank(message = "Image URL is required")
        @Size(max = 1000, message = "Image URL must not exceed 1000 characters")
        String imageUrl,

        @Min(value = 0, message = "Display order cannot be negative")
        Integer displayOrder,

        boolean primary
) {
}