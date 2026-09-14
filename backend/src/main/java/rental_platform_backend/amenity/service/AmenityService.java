package rental_platform_backend.amenity.service;

import rental_platform_backend.amenity.dto.AmenityResponse;
import rental_platform_backend.amenity.dto.CreateAmenityRequest;
import rental_platform_backend.amenity.entity.Amenity;
import rental_platform_backend.amenity.entity.PropertyAmenity;
import rental_platform_backend.amenity.entity.PropertyAmenityId;
import rental_platform_backend.amenity.repository.AmenityRepository;
import rental_platform_backend.amenity.repository.PropertyAmenityRepository;
import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.repository.PropertyRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class AmenityService {

    private final AmenityRepository amenityRepository;
    private final PropertyAmenityRepository propertyAmenityRepository;
    private final PropertyRepository propertyRepository;

    public AmenityService(
            AmenityRepository amenityRepository,
            PropertyAmenityRepository propertyAmenityRepository,
            PropertyRepository propertyRepository
    ) {
        this.amenityRepository = amenityRepository;
        this.propertyAmenityRepository = propertyAmenityRepository;
        this.propertyRepository = propertyRepository;
    }

    // =========================
    // ADMIN: CREATE AMENITY
    // =========================

    @Transactional
    public AmenityResponse createAmenity(
            CreateAmenityRequest request
    ) {

        String name = request.name().trim();

        if (amenityRepository.existsByNameIgnoreCase(name)) {
            throw new IllegalStateException(
                    "Amenity already exists"
            );
        }

        Amenity amenity = new Amenity();
        amenity.setName(name);

        Amenity saved = amenityRepository.save(amenity);

        return toResponse(saved);
    }

    // =========================
    // PUBLIC: GET AMENITIES
    // =========================

    @Transactional(readOnly = true)
    public List<AmenityResponse> getAllAmenities() {

        return amenityRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    // =========================
    // ADMIN: DELETE AMENITY
    // =========================

    @Transactional
    public void deleteAmenity(UUID amenityId) {

        Amenity amenity = amenityRepository.findById(amenityId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Amenity not found"
                        ));

        amenityRepository.delete(amenity);
    }

    // =========================
    // OWNER / ADMIN:
    // ADD AMENITY TO PROPERTY
    // =========================

    @Transactional
    public void addAmenityToProperty(
            UUID propertyId,
            UUID amenityId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Property not found"
                        ));

        validatePropertyAccess(
                property,
                currentUserId,
                isAdmin
        );

        Amenity amenity = amenityRepository.findById(amenityId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Amenity not found"
                        ));

        if (propertyAmenityRepository
                .existsByPropertyIdAndAmenityId(
                        propertyId,
                        amenityId
                )) {

            throw new IllegalStateException(
                    "Amenity is already assigned to this property"
            );
        }

        PropertyAmenityId id =
                new PropertyAmenityId(
                        propertyId,
                        amenityId
                );

        PropertyAmenity propertyAmenity =
                new PropertyAmenity(
                        id,
                        property,
                        amenity
                );

        propertyAmenityRepository.save(propertyAmenity);
    }

    // =========================
    // PUBLIC:
    // GET PROPERTY AMENITIES
    // =========================

    @Transactional(readOnly = true)
    public List<AmenityResponse> getPropertyAmenities(
            UUID propertyId
    ) {

        if (!propertyRepository.existsById(propertyId)) {
            throw new ResourceNotFoundException(
                    "Property not found"
            );
        }

        return propertyAmenityRepository
                .findByPropertyId(propertyId)
                .stream()
                .map(PropertyAmenity::getAmenity)
                .map(this::toResponse)
                .toList();
    }

    // =========================
    // OWNER / ADMIN:
    // REMOVE AMENITY
    // =========================

    @Transactional
    public void removeAmenityFromProperty(
            UUID propertyId,
            UUID amenityId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Property not found"
                        ));

        validatePropertyAccess(
                property,
                currentUserId,
                isAdmin
        );

        PropertyAmenityId id =
                new PropertyAmenityId(
                        propertyId,
                        amenityId
                );

        if (!propertyAmenityRepository.existsById(id)) {
            throw new ResourceNotFoundException(
                    "Amenity is not assigned to this property"
            );
        }

        propertyAmenityRepository.deleteById(id);
    }

    private void validatePropertyAccess(
            Property property,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        if (!property.getOwner().getId().equals(currentUserId)) {
            throw new IllegalStateException(
                    "You are not authorized to manage this property"
            );
        }
    }

    private AmenityResponse toResponse(Amenity amenity) {

        return new AmenityResponse(
                amenity.getId(),
                amenity.getName(),
                amenity.getCreatedAt()
        );
    }
}