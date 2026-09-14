
package rental_platform_backend.lease.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import rental_platform_backend.lease.entity.Lease;
import rental_platform_backend.lease.entity.LeaseStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface LeaseRepository extends JpaRepository<Lease, UUID> {

    Optional<Lease> findByRentalRequestId(UUID rentalRequestId);

    List<Lease> findByPropertyId(UUID propertyId);

    List<Lease> findByTenantId(UUID tenantId);

    List<Lease> findByTenantUserId(UUID userId);
    
    List<Lease> findByOwnerId(UUID ownerId);

    List<Lease> findByTenantIdAndStatus(
            UUID tenantId,
            LeaseStatus status
    );

    List<Lease> findByOwnerIdAndStatus(
            UUID ownerId,
            LeaseStatus status
    );

    Optional<Lease> findByPropertyIdAndStatus(
            UUID propertyId,
            LeaseStatus status
    );

    boolean existsByRentalRequestId(UUID rentalRequestId);

    boolean existsByPropertyIdAndStatus(
            UUID propertyId,
            LeaseStatus status
    );
    List<Lease> findByStatus(LeaseStatus status);
}

