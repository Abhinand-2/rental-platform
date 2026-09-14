package rental_platform_backend.amenity.repository;

import rental_platform_backend.amenity.entity.Amenity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface AmenityRepository
        extends JpaRepository<Amenity, UUID> {

    boolean existsByNameIgnoreCase(String name);
}