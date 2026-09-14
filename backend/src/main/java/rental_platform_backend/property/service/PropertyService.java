
package rental_platform_backend.property.service;

import rental_platform_backend.common.exception.ForbiddenOperationException;
import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.property.dto.CreatePropertyRequest;
import rental_platform_backend.property.dto.PropertyResponse;
import rental_platform_backend.property.dto.UpdatePropertyRequest;
import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.entity.PropertyStatus;
import rental_platform_backend.property.repository.PropertyRepository;
import rental_platform_backend.user.entity.Role;
import rental_platform_backend.user.entity.User;
import rental_platform_backend.user.repository.UserRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;

    public PropertyService(
            PropertyRepository propertyRepository,
            UserRepository userRepository) {

        this.propertyRepository = propertyRepository;
        this.userRepository = userRepository;
    }

    // =========================================================
    // CREATE
    // =========================================================

    @Transactional
    public PropertyResponse createProperty(
            UUID ownerId,
            CreatePropertyRequest request) {

        User owner = userRepository.findById(ownerId)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Owner not found"));

        if (owner.getRole() != Role.OWNER) {
            throw new ForbiddenOperationException(
                    "Only users with OWNER role can create properties"
            );
        }

        Property property = new Property();

        property.setOwner(owner);

        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setType(request.getType());

        property.setStatus(PropertyStatus.PENDING_APPROVAL);

        property.setAddressLine(request.getAddressLine());
        property.setCity(request.getCity());
        property.setState(request.getState());
        property.setPostalCode(request.getPostalCode());

        property.setLatitude(request.getLatitude());
        property.setLongitude(request.getLongitude());

        property.setBedrooms(request.getBedrooms());
        property.setBathrooms(request.getBathrooms());

        property.setAreaSqFt(request.getAreaSqFt());

        property.setMonthlyRent(request.getMonthlyRent());
        property.setSecurityDeposit(request.getSecurityDeposit());

        Property savedProperty =
                propertyRepository.save(property);

        return convertToResponse(savedProperty);
    }

    // =========================================================
    // READ
    // =========================================================

    @Transactional(readOnly = true)
    public PropertyResponse getPropertyById(UUID id) {

        Property property = findProperty(id);

        return convertToResponse(property);
    }

    @Transactional(readOnly = true)
    public List<PropertyResponse> getAllProperties() {

        return propertyRepository.findAll()
                .stream()
                .map(this::convertToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PropertyResponse> getPropertiesByOwner(
            UUID ownerId) {

        if (!userRepository.existsById(ownerId)) {
            throw new ResourceNotFoundException(
                    "Owner not found with id: " + ownerId
            );
        }

        return propertyRepository.findByOwnerId(ownerId)
                .stream()
                .map(this::convertToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PropertyResponse> getPublishedProperties() {

        return propertyRepository
                .findByStatus(PropertyStatus.PUBLISHED)
                .stream()
                .map(this::convertToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PropertyResponse> getPublishedPropertiesByCity(
            String city) {

        return propertyRepository
                .findByCityIgnoreCaseAndStatus(
                        city,
                        PropertyStatus.PUBLISHED
                )
                .stream()
                .map(this::convertToResponse)
                .toList();
    }

    // =========================================================
    // UPDATE
    // =========================================================

    @Transactional
    public PropertyResponse updateProperty(
            UUID id,
            UUID currentUserId,
            UpdatePropertyRequest request) {

        Property property = findProperty(id);

        validateOwner(property, currentUserId);

        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setType(request.getType());

        property.setAddressLine(request.getAddressLine());
        property.setCity(request.getCity());
        property.setState(request.getState());
        property.setPostalCode(request.getPostalCode());

        property.setLatitude(request.getLatitude());
        property.setLongitude(request.getLongitude());

        property.setBedrooms(request.getBedrooms());
        property.setBathrooms(request.getBathrooms());

        property.setAreaSqFt(request.getAreaSqFt());

        property.setMonthlyRent(request.getMonthlyRent());
        property.setSecurityDeposit(request.getSecurityDeposit());

        /*
         * Status is deliberately not changed here.
         *
         * Approval and publication are separate business operations.
         */

        return convertToResponse(
                propertyRepository.save(property)
        );
    }

    // =========================================================
    // DELETE
    // =========================================================

    @Transactional
    public void deleteProperty(
            UUID id,
            UUID currentUserId) {

        Property property = findProperty(id);

        validateOwner(property, currentUserId);

        propertyRepository.delete(property);
    }

    // =========================================================
    // ADMIN APPROVAL
    // =========================================================

    @Transactional
    public PropertyResponse approveProperty(UUID id) {

        Property property = findProperty(id);

        if (property.getStatus() != PropertyStatus.PENDING_APPROVAL) {
            throw new IllegalStateException(
                    "Only properties pending approval can be approved"
            );
        }

        property.setStatus(PropertyStatus.APPROVED);

        return convertToResponse(
                propertyRepository.save(property)
        );
    }

    // =========================================================
    // ADMIN REJECTION
    // =========================================================

    @Transactional
    public PropertyResponse rejectProperty(UUID id) {

        Property property = findProperty(id);

        if (property.getStatus() != PropertyStatus.PENDING_APPROVAL) {
            throw new IllegalStateException(
                    "Only properties pending approval can be rejected"
            );
        }

        property.setStatus(PropertyStatus.REJECTED);

        return convertToResponse(
                propertyRepository.save(property)
        );
    }

    // =========================================================
    // PUBLISH
    // =========================================================

    @Transactional
    public PropertyResponse publishProperty(
            UUID id,
            UUID currentUserId) {

        Property property = findProperty(id);

        /*
         * Only the property owner can publish their property
         * through this operation.
         */
        validateOwner(property, currentUserId);

        if (property.getStatus() != PropertyStatus.APPROVED) {
            throw new IllegalStateException(
                    "Only approved properties can be published"
            );
        }

        property.setStatus(PropertyStatus.PUBLISHED);

        return convertToResponse(
                propertyRepository.save(property)
        );
    }

    // =========================================================
    // HELPER METHODS
    // =========================================================

    private Property findProperty(UUID id) {

        return propertyRepository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Property not found with id: " + id
                        )
                );
    }

    private void validateOwner(
            Property property,
            UUID currentUserId) {

        if (!property.getOwner().getId().equals(currentUserId)) {
            throw new ForbiddenOperationException(
                    "You are not authorized to manage this property"
            );
        }
    }

    // =========================================================
    // RESPONSE MAPPING
    // =========================================================

    private PropertyResponse convertToResponse(
            Property property) {

        PropertyResponse response = new PropertyResponse();

        response.setId(property.getId());

        response.setOwnerId(
                property.getOwner().getId()
        );

        response.setTitle(property.getTitle());
        response.setDescription(property.getDescription());

        response.setType(property.getType());
        response.setStatus(property.getStatus());

        response.setAddressLine(property.getAddressLine());
        response.setCity(property.getCity());
        response.setState(property.getState());
        response.setPostalCode(property.getPostalCode());

        response.setLatitude(property.getLatitude());
        response.setLongitude(property.getLongitude());

        response.setBedrooms(property.getBedrooms());
        response.setBathrooms(property.getBathrooms());

        response.setAreaSqFt(property.getAreaSqFt());

        response.setMonthlyRent(property.getMonthlyRent());
        response.setSecurityDeposit(property.getSecurityDeposit());

        response.setCreatedAt(property.getCreatedAt());
        response.setUpdatedAt(property.getUpdatedAt());

        return response;
    }
}

