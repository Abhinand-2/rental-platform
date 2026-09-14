package rental_platform_backend.propertyimage.repository;

import rental_platform_backend.propertyimage.entity.PropertyImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PropertyImageRepository
        extends JpaRepository<PropertyImage, UUID> {

    List<PropertyImage> findByPropertyIdOrderByDisplayOrderAsc(UUID propertyId);

    Optional<PropertyImage> findByIdAndPropertyId(
            UUID imageId,
            UUID propertyId
    );

    boolean existsByPropertyIdAndDisplayOrder(
            UUID propertyId,
            Integer displayOrder
    );

    Optional<PropertyImage> findByPropertyIdAndPrimaryTrue(
            UUID propertyId
    );
}