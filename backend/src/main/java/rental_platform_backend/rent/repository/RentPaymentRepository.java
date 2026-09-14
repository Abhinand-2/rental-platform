package rental_platform_backend.rent.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import rental_platform_backend.rent.entity.RentPayment;
import rental_platform_backend.rent.entity.RentPaymentStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RentPaymentRepository
        extends JpaRepository<RentPayment, UUID> {

    Optional<RentPayment> findByRentChargeId(UUID rentChargeId);

    List<RentPayment> findByRentChargeLeaseTenantUserId(UUID userId);

    List<RentPayment> findByRentChargeLeaseOwnerId(UUID ownerId);

    List<RentPayment> findByStatus(RentPaymentStatus status);

    boolean existsByRentChargeId(UUID rentChargeId);
}