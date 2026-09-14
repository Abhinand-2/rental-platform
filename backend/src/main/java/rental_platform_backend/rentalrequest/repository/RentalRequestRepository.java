package rental_platform_backend.rentalrequest.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import rental_platform_backend.rentalrequest.entity.RentalRequest;
import rental_platform_backend.rentalrequest.entity.RentalRequestStatus;

import java.util.List;
import java.util.UUID;

public interface RentalRequestRepository
        extends JpaRepository<RentalRequest, UUID> {

    List<RentalRequest> findByApplicantUserId(UUID applicantUserId);

    List<RentalRequest> findByApplicantUserIdAndStatus(
            UUID applicantUserId,
            RentalRequestStatus status
    );

    List<RentalRequest> findByPropertyId(UUID propertyId);

    List<RentalRequest> findByPropertyOwnerId(UUID ownerId);

    List<RentalRequest> findByPropertyOwnerIdAndStatus(
            UUID ownerId,
            RentalRequestStatus status
    );

    boolean existsByPropertyIdAndApplicantUserIdAndStatus(
            UUID propertyId,
            UUID applicantUserId,
            RentalRequestStatus status
    );
}