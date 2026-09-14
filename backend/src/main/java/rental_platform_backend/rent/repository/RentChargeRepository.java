package rental_platform_backend.rent.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import rental_platform_backend.rent.entity.RentCharge;
import rental_platform_backend.rent.entity.RentChargeStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RentChargeRepository
        extends JpaRepository<RentCharge, UUID> {

    List<RentCharge> findByLeaseId(UUID leaseId);

    List<RentCharge> findByLeaseTenantUserId(UUID userId);

    List<RentCharge> findByLeaseOwnerId(UUID ownerId);

    List<RentCharge> findByStatus(RentChargeStatus status);

    Optional<RentCharge> findByLeaseIdAndBillingYearAndBillingMonth(
            UUID leaseId,
            Integer billingYear,
            Integer billingMonth
    );

    boolean existsByLeaseIdAndBillingYearAndBillingMonth(
            UUID leaseId,
            Integer billingYear,
            Integer billingMonth
    );
    
}