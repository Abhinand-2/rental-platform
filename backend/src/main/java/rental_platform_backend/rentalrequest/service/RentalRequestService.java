package rental_platform_backend.rentalrequest.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import rental_platform_backend.common.exception.ForbiddenOperationException;
import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.entity.PropertyStatus;
import rental_platform_backend.property.repository.PropertyRepository;
import rental_platform_backend.rentalrequest.dto.CreateRentalRequest;
import rental_platform_backend.rentalrequest.dto.RentalRequestResponse;
import rental_platform_backend.rentalrequest.entity.RentalRequest;
import rental_platform_backend.rentalrequest.entity.RentalRequestStatus;
import rental_platform_backend.rentalrequest.repository.RentalRequestRepository;
import rental_platform_backend.lease.repository.LeaseRepository;
import rental_platform_backend.user.entity.User;
import rental_platform_backend.user.repository.UserRepository;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class RentalRequestService {

    private final RentalRequestRepository rentalRequestRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final LeaseRepository leaseRepository;

    public RentalRequestService(
            RentalRequestRepository rentalRequestRepository,
            PropertyRepository propertyRepository,
            UserRepository userRepository,
            LeaseRepository leaseRepository
    ) {
        this.rentalRequestRepository = rentalRequestRepository;
        this.propertyRepository = propertyRepository;
        this.userRepository = userRepository;
        this.leaseRepository = leaseRepository;
    }

    public RentalRequestResponse createRequest(
            CreateRentalRequest request,
            UUID applicantUserId
    ) {

        User applicant = userRepository.findById(applicantUserId)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Applicant user not found")
                );

        Property property = propertyRepository.findById(request.propertyId())
                .orElseThrow(() ->
                        new ResourceNotFoundException("Property not found")
                );

        if (property.getStatus() != PropertyStatus.PUBLISHED) {
            throw new ForbiddenOperationException(
                    "Rental requests can only be submitted for published properties"
            );
        }

        if (property.getOwner().getId().equals(applicantUserId)) {
            throw new ForbiddenOperationException(
                    "Property owner cannot submit a rental request for their own property"
            );
        }

        boolean alreadyPending =
                rentalRequestRepository
                        .existsByPropertyIdAndApplicantUserIdAndStatus(
                                property.getId(),
                                applicantUserId,
                                RentalRequestStatus.PENDING
                        );

        if (alreadyPending) {
            throw new IllegalStateException(
                    "You already have a pending rental request for this property"
            );
        }

        RentalRequest rentalRequest = new RentalRequest();

        rentalRequest.setProperty(property);
        rentalRequest.setApplicantUser(applicant);
        rentalRequest.setMessage(request.message());
        rentalRequest.setRequestedStartDate(request.requestedStartDate());
        rentalRequest.setStatus(RentalRequestStatus.PENDING);

        RentalRequest saved =
                rentalRequestRepository.save(rentalRequest);

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public RentalRequestResponse getRequest(
            UUID requestId,
            UUID currentUserId
    ) {

        RentalRequest rentalRequest = getRequestEntity(requestId);

        validateViewAccess(rentalRequest, currentUserId);

        return toResponse(rentalRequest);
    }

    @Transactional(readOnly = true)
    public List<RentalRequestResponse> getMyRequests(
            UUID applicantUserId
    ) {

        return rentalRequestRepository
                .findByApplicantUserId(applicantUserId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RentalRequestResponse> getOwnerRequests(
            UUID ownerId
    ) {

        return rentalRequestRepository
                .findByPropertyOwnerId(ownerId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RentalRequestResponse> getAllRequests() {

        return rentalRequestRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public RentalRequestResponse approveRequest(
            UUID requestId,
            UUID ownerId
    ) {

        RentalRequest rentalRequest = getRequestEntity(requestId);

        validateOwnerAccess(rentalRequest, ownerId);

        if (rentalRequest.getStatus() != RentalRequestStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending rental requests can be approved"
            );
        }

        rentalRequest.setStatus(RentalRequestStatus.APPROVED);

        return toResponse(
                rentalRequestRepository.save(rentalRequest)
        );
    }

    public RentalRequestResponse rejectRequest(
            UUID requestId,
            UUID ownerId
    ) {

        RentalRequest rentalRequest = getRequestEntity(requestId);

        validateOwnerAccess(rentalRequest, ownerId);

        if (rentalRequest.getStatus() != RentalRequestStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending rental requests can be rejected"
            );
        }

        rentalRequest.setStatus(RentalRequestStatus.REJECTED);

        return toResponse(
                rentalRequestRepository.save(rentalRequest)
        );
    }

    public RentalRequestResponse cancelRequest(
            UUID requestId,
            UUID applicantUserId
    ) {

        RentalRequest rentalRequest = getRequestEntity(requestId);

        if (!rentalRequest.getApplicantUser().getId()
                .equals(applicantUserId)) {

            throw new ForbiddenOperationException(
                    "You can only cancel your own rental requests"
            );
        }

        if (rentalRequest.getStatus() != RentalRequestStatus.PENDING) {
            throw new IllegalStateException(
                    "Only pending rental requests can be cancelled"
            );
        }

        rentalRequest.setStatus(RentalRequestStatus.CANCELLED);

        return toResponse(
                rentalRequestRepository.save(rentalRequest)
        );
    }

    private RentalRequest getRequestEntity(UUID requestId) {

        return rentalRequestRepository.findById(requestId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Rental request not found"
                        )
                );
    }

    private void validateOwnerAccess(
            RentalRequest rentalRequest,
            UUID ownerId
    ) {

        UUID propertyOwnerId =
                rentalRequest.getProperty()
                        .getOwner()
                        .getId();

        if (!propertyOwnerId.equals(ownerId)) {
            throw new ForbiddenOperationException(
                    "You are not authorized to manage this rental request"
            );
        }
    }

    private void validateViewAccess(
            RentalRequest rentalRequest,
            UUID currentUserId
    ) {

        UUID applicantId =
                rentalRequest.getApplicantUser().getId();

        UUID ownerId =
                rentalRequest.getProperty()
                        .getOwner()
                        .getId();

        if (!currentUserId.equals(applicantId)
                && !currentUserId.equals(ownerId)) {

            throw new ForbiddenOperationException(
                    "You are not authorized to view this rental request"
            );
        }
    }

    private RentalRequestResponse toResponse(
            RentalRequest rentalRequest
    ) {

        User applicant = rentalRequest.getApplicantUser();
        Property property = rentalRequest.getProperty();

        String applicantName = buildFullName(
                applicant.getFirstName(),
                applicant.getLastName()
        );

        boolean leaseExists =
                leaseRepository.existsByRentalRequestId(
                        rentalRequest.getId()
                );

        return new RentalRequestResponse(
                rentalRequest.getId(),
                property.getId(),
                property.getTitle(),
                applicant.getId(),
                applicantName,
                applicant.getEmail(),
                rentalRequest.getMessage(),
                rentalRequest.getRequestedStartDate(),
                rentalRequest.getStatus(),
                leaseExists,
                rentalRequest.getCreatedAt(),
                rentalRequest.getUpdatedAt()
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