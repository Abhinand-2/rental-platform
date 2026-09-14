package rental_platform_backend.property.repository;

import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.entity.PropertyStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PropertyRepository
        extends JpaRepository<Property, UUID> {

    List<Property> findByOwnerId(UUID ownerId);

    List<Property> findByOwnerIdAndStatus(
            UUID ownerId,
            PropertyStatus status
    );

    List<Property> findByStatus(PropertyStatus status);

    List<Property> findByCityIgnoreCaseAndStatus(
            String city,
            PropertyStatus status
    );
}
