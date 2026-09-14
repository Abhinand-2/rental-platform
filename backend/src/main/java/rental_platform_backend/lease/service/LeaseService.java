package rental_platform_backend.lease.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import rental_platform_backend.common.exception.ForbiddenOperationException;
import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.lease.dto.CreateLeaseRequest;
import rental_platform_backend.lease.dto.LeaseResponse;
import rental_platform_backend.lease.entity.Lease;
import rental_platform_backend.lease.entity.LeaseStatus;
import rental_platform_backend.lease.repository.LeaseRepository;
import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.entity.PropertyStatus;
import rental_platform_backend.property.repository.PropertyRepository;
import rental_platform_backend.rentalrequest.entity.RentalRequest;
import rental_platform_backend.rentalrequest.entity.RentalRequestStatus;
import rental_platform_backend.rentalrequest.repository.RentalRequestRepository;
import rental_platform_backend.rent.service.RentService;
import rental_platform_backend.tenant.entity.Tenant;
import rental_platform_backend.tenant.service.TenantService;
import rental_platform_backend.user.entity.User;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class LeaseService {

    private final LeaseRepository leaseRepository;
    private final RentalRequestRepository rentalRequestRepository;
    private final PropertyRepository propertyRepository;
    private final TenantService tenantService;
    private final RentService rentService;

    public LeaseService(
            LeaseRepository leaseRepository,
            RentalRequestRepository rentalRequestRepository,
            PropertyRepository propertyRepository,
            TenantService tenantService,
            RentService rentService
    ) {
        this.leaseRepository = leaseRepository;
        this.rentalRequestRepository = rentalRequestRepository;
        this.propertyRepository = propertyRepository;
        this.tenantService = tenantService;
        this.rentService = rentService;
    }

    public LeaseResponse createLease(
            CreateLeaseRequest request,
            UUID currentUserId,
            boolean isAdmin
    ) {

        RentalRequest rentalRequest =
                rentalRequestRepository.findById(request.rentalRequestId())
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Rental request not found"
                                )
                        );

        if (rentalRequest.getStatus()
                != RentalRequestStatus.APPROVED) {

            throw new IllegalStateException(
                    "Only approved rental requests can be converted into a lease"
            );
        }

        if (leaseRepository.existsByRentalRequestId(
                rentalRequest.getId())) {

            throw new IllegalStateException(
                    "A lease already exists for this rental request"
            );
        }

        Property property = rentalRequest.getProperty();

        User owner = property.getOwner();

        if (!isAdmin &&
                !owner.getId().equals(currentUserId)) {

            throw new ForbiddenOperationException(
                    "You are not authorized to create a lease for this property"
            );
        }

        if (property.getStatus() != PropertyStatus.PUBLISHED) {

            throw new IllegalStateException(
                    "A lease can only be created for a published property"
            );
        }

        if (leaseRepository.existsByPropertyIdAndStatus(
                property.getId(),
                LeaseStatus.ACTIVE)) {

            throw new IllegalStateException(
                    "This property already has an active lease"
            );
        }

        validateDates(
                request.startDate(),
                request.endDate()
        );

        User tenantUser = rentalRequest.getApplicantUser();

        tenantService.createTenant(tenantUser.getId());

        Tenant tenant =
                tenantService.getTenantEntityByUserId(
                        tenantUser.getId()
                );

        Lease lease = new Lease();

        lease.setRentalRequest(rentalRequest);
        lease.setProperty(property);
        lease.setTenant(tenant);
        lease.setOwner(owner);
        lease.setStartDate(request.startDate());
        lease.setEndDate(request.endDate());
        lease.setMonthlyRent(request.monthlyRent());
        lease.setSecurityDeposit(request.securityDeposit());
        lease.setStatus(LeaseStatus.ACTIVE);

        Lease savedLease = leaseRepository.save(lease);

        /*
         * The property is no longer available for new rental requests.
         */
        property.setStatus(PropertyStatus.RENTED);

        propertyRepository.save(property);

        /*
         * Automatically create the first rent charge.
         *
         * This happens inside the same transaction.
         * If rent creation fails, the lease creation also rolls back.
         */
        rentService.createInitialRentCharge(savedLease);

        return toResponse(savedLease);
    }

    @Transactional(readOnly = true)
    public LeaseResponse getLeaseById(
            UUID leaseId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Lease lease = getLeaseEntity(leaseId);

        validateViewAccess(
                lease,
                currentUserId,
                isAdmin
        );

        return toResponse(lease);
    }

    @Transactional(readOnly = true)
    public List<LeaseResponse> getMyLeases(
            UUID tenantUserId
    ) {

        return leaseRepository
                .findByTenantUserId(tenantUserId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LeaseResponse> getOwnerLeases(
            UUID ownerId
    ) {

        return leaseRepository
                .findByOwnerId(ownerId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LeaseResponse> getAllLeases() {

        return leaseRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public LeaseResponse terminateLease(
            UUID leaseId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Lease lease = getLeaseEntity(leaseId);

        validateManageAccess(
                lease,
                currentUserId,
                isAdmin
        );

        if (lease.getStatus() != LeaseStatus.ACTIVE) {

            throw new IllegalStateException(
                    "Only active leases can be terminated"
            );
        }

        lease.setStatus(LeaseStatus.TERMINATED);

        Property property = lease.getProperty();

        /*
         * The property becomes available again.
         */
        property.setStatus(PropertyStatus.PUBLISHED);

        propertyRepository.save(property);

        return toResponse(
                leaseRepository.save(lease)
        );
    }

    public LeaseResponse cancelLease(
            UUID leaseId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Lease lease = getLeaseEntity(leaseId);

        validateManageAccess(
                lease,
                currentUserId,
                isAdmin
        );

        if (lease.getStatus() != LeaseStatus.ACTIVE
                && lease.getStatus() != LeaseStatus.DRAFT) {

            throw new IllegalStateException(
                    "Only active or draft leases can be cancelled"
            );
        }

        lease.setStatus(LeaseStatus.CANCELLED);

        Property property = lease.getProperty();

        if (property.getStatus() == PropertyStatus.RENTED) {
            property.setStatus(PropertyStatus.PUBLISHED);
            propertyRepository.save(property);
        }

        return toResponse(
                leaseRepository.save(lease)
        );
    }

    private Lease getLeaseEntity(UUID leaseId) {

        return leaseRepository.findById(leaseId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Lease not found"
                        )
                );
    }

    private void validateDates(
            LocalDate startDate,
            LocalDate endDate
    ) {

        if (!endDate.isAfter(startDate)) {

            throw new IllegalArgumentException(
                    "Lease end date must be after start date"
            );
        }
    }

    private void validateViewAccess(
            Lease lease,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        UUID ownerId =
                lease.getOwner().getId();

        UUID tenantUserId =
                lease.getTenant()
                        .getUser()
                        .getId();

        if (!currentUserId.equals(ownerId)
                && !currentUserId.equals(tenantUserId)) {

            throw new ForbiddenOperationException(
                    "You are not authorized to view this lease"
            );
        }
    }

    private void validateManageAccess(
            Lease lease,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        if (!lease.getOwner()
                .getId()
                .equals(currentUserId)) {

            throw new ForbiddenOperationException(
                    "You are not authorized to manage this lease"
            );
        }
    }

    private LeaseResponse toResponse(
            Lease lease
    ) {

        Property property = lease.getProperty();
        User owner = lease.getOwner();
        User tenantUser = lease.getTenant().getUser();

        return new LeaseResponse(
                lease.getId(),

                lease.getRentalRequest().getId(),

                property.getId(),
                property.getTitle(),

                lease.getTenant().getId(),
                tenantUser.getId(),
                buildFullName(
                        tenantUser.getFirstName(),
                        tenantUser.getLastName()
                ),
                tenantUser.getEmail(),

                owner.getId(),
                buildFullName(
                        owner.getFirstName(),
                        owner.getLastName()
                ),
                owner.getEmail(),

                lease.getStartDate(),
                lease.getEndDate(),
                lease.getMonthlyRent(),
                lease.getSecurityDeposit(),
                lease.getStatus(),
                lease.getCreatedAt(),
                lease.getUpdatedAt()
        );
    }

    private String buildFullName(
            String firstName,
            String lastName
    ) {

        if (lastName == null || lastName.isBlank()) {
            return firstName;
        }

        return firstName + " " + lastName;
    }
}