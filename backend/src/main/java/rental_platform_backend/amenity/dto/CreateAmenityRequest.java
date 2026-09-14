package rental_platform_backend.amenity.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateAmenityRequest(

        @NotBlank(message = "Amenity name is required")
        @Size(max = 100, message = "Amenity name must not exceed 100 characters")
        String name

) {
}