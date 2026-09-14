package rental_platform_backend.amenity.repository;

import rental_platform_backend.amenity.entity.PropertyAmenity;
import rental_platform_backend.amenity.entity.PropertyAmenityId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PropertyAmenityRepository
        extends JpaRepository<PropertyAmenity, PropertyAmenityId> {

    List<PropertyAmenity> findByPropertyId(UUID propertyId);

    boolean existsByPropertyIdAndAmenityId(
            UUID propertyId,
            UUID amenityId
    );
}