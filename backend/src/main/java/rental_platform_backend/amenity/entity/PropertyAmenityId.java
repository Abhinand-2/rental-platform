package rental_platform_backend.amenity.entity;

import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

@Embeddable
public class PropertyAmenityId implements Serializable {

    private UUID propertyId;

    private UUID amenityId;

    public PropertyAmenityId() {
    }

    public PropertyAmenityId(
            UUID propertyId,
            UUID amenityId
    ) {
        this.propertyId = propertyId;
        this.amenityId = amenityId;
    }

    public UUID getPropertyId() {
        return propertyId;
    }

    public UUID getAmenityId() {
        return amenityId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (!(o instanceof PropertyAmenityId that)) {
            return false;
        }

        return Objects.equals(propertyId, that.propertyId)
                && Objects.equals(amenityId, that.amenityId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(propertyId, amenityId);
    }
}