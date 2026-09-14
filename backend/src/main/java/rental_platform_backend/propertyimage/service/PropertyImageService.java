package rental_platform_backend.propertyimage.service;

import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.property.entity.Property;
import rental_platform_backend.property.repository.PropertyRepository;
import rental_platform_backend.propertyimage.dto.CreatePropertyImageRequest;
import rental_platform_backend.propertyimage.dto.PropertyImageResponse;
import rental_platform_backend.propertyimage.entity.PropertyImage;
import rental_platform_backend.propertyimage.repository.PropertyImageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class PropertyImageService {

    private final PropertyImageRepository propertyImageRepository;
    private final PropertyRepository propertyRepository;

    public PropertyImageService(
            PropertyImageRepository propertyImageRepository,
            PropertyRepository propertyRepository
    ) {
        this.propertyImageRepository = propertyImageRepository;
        this.propertyRepository = propertyRepository;
    }

    @Transactional
    public PropertyImageResponse addImage(
            UUID propertyId,
            UUID currentUserId,
            CreatePropertyImageRequest request,
            boolean isAdmin
    ) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Property not found"));

        validateAccess(property, currentUserId, isAdmin);

        Integer displayOrder =
                request.displayOrder() != null
                        ? request.displayOrder()
                        : 0;

        if (propertyImageRepository.existsByPropertyIdAndDisplayOrder(
                propertyId,
                displayOrder
        )) {
            throw new IllegalStateException(
                    "An image already exists at display order " + displayOrder
            );
        }

        if (request.primary()) {
            removeExistingPrimary(propertyId);
        }

        PropertyImage image = new PropertyImage();

        image.setProperty(property);
        image.setImageUrl(request.imageUrl());
        image.setDisplayOrder(displayOrder);
        image.setPrimary(request.primary());

        PropertyImage saved = propertyImageRepository.save(image);

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<PropertyImageResponse> getImages(UUID propertyId) {

        if (!propertyRepository.existsById(propertyId)) {
            throw new ResourceNotFoundException("Property not found");
        }

        return propertyImageRepository
                .findByPropertyIdOrderByDisplayOrderAsc(propertyId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public void deleteImage(
            UUID propertyId,
            UUID imageId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Property not found"));

        validateAccess(property, currentUserId, isAdmin);

        PropertyImage image =
                propertyImageRepository
                        .findByIdAndPropertyId(imageId, propertyId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Property image not found"
                                ));

        propertyImageRepository.delete(image);
    }

    @Transactional
    public PropertyImageResponse setPrimary(
            UUID propertyId,
            UUID imageId,
            UUID currentUserId,
            boolean isAdmin
    ) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Property not found"));

        validateAccess(property, currentUserId, isAdmin);

        PropertyImage image =
                propertyImageRepository
                        .findByIdAndPropertyId(imageId, propertyId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Property image not found"
                                ));

        removeExistingPrimary(propertyId);

        image.setPrimary(true);

        PropertyImage saved = propertyImageRepository.save(image);

        return toResponse(saved);
    }

    private void removeExistingPrimary(UUID propertyId) {

        propertyImageRepository
                .findByPropertyIdAndPrimaryTrue(propertyId)
                .ifPresent(existing -> {
                    existing.setPrimary(false);
                    propertyImageRepository.save(existing);
                });
    }

    private void validateAccess(
            Property property,
            UUID currentUserId,
            boolean isAdmin
    ) {

        if (isAdmin) {
            return;
        }

        if (!property.getOwner().getId().equals(currentUserId)) {
            throw new IllegalStateException(
                    "You are not authorized to manage images for this property"
            );
        }
    }

    private PropertyImageResponse toResponse(PropertyImage image) {

        return new PropertyImageResponse(
                image.getId(),
                image.getProperty().getId(),
                image.getImageUrl(),
                image.getDisplayOrder(),
                image.isPrimary(),
                image.getCreatedAt()
        );
    }
}