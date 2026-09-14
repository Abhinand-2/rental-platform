package rental_platform_backend.property.controller;


import rental_platform_backend.property.dto.CreatePropertyRequest;
import rental_platform_backend.property.dto.PropertyResponse;
import rental_platform_backend.property.dto.UpdatePropertyRequest;
import rental_platform_backend.property.service.PropertyService;
import jakarta.validation.Valid;

import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/properties")
public class PropertyController {

    private final PropertyService propertyService;

    public PropertyController(
            PropertyService propertyService) {

        this.propertyService = propertyService;
    }

   @PostMapping
@PreAuthorize("hasRole('OWNER')")
public ResponseEntity<PropertyResponse> create(
        @Valid @RequestBody CreatePropertyRequest request,
        Authentication authentication
) {

    CustomUserPrincipal principal =
            (CustomUserPrincipal) authentication.getPrincipal();

    PropertyResponse response =
            propertyService.createProperty(
                    principal.getUserId(),
                    request
            );

    return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(response);
}

    @GetMapping("/{id}")
    public ResponseEntity<PropertyResponse> getPropertyById(
            @PathVariable UUID id) {

        return ResponseEntity.ok(
                propertyService.getPropertyById(id)
        );
    }

    @GetMapping
    public ResponseEntity<List<PropertyResponse>> getAllProperties() {

        return ResponseEntity.ok(
                propertyService.getAllProperties()
        );
    }

    @GetMapping("/owner/{ownerId}")
    public ResponseEntity<List<PropertyResponse>> getPropertiesByOwner(
            @PathVariable UUID ownerId) {

        return ResponseEntity.ok(
                propertyService.getPropertiesByOwner(ownerId)
        );
    }

    @GetMapping("/published")
    public ResponseEntity<List<PropertyResponse>>
    getPublishedProperties() {

        return ResponseEntity.ok(
                propertyService.getPublishedProperties()
        );
    }

    @GetMapping("/published/city/{city}")
    public ResponseEntity<List<PropertyResponse>>
    getPublishedPropertiesByCity(
            @PathVariable String city) {

        return ResponseEntity.ok(
                propertyService.getPublishedPropertiesByCity(city)
        );
    }


@PutMapping("/{id}")
@PreAuthorize("hasRole('OWNER')")
public ResponseEntity<PropertyResponse> updateProperty(
        @PathVariable UUID id,
        @Valid @RequestBody UpdatePropertyRequest request,
        Authentication authentication) {

    CustomUserPrincipal principal =
            (CustomUserPrincipal) authentication.getPrincipal();

    return ResponseEntity.ok(
            propertyService.updateProperty(
                    id,
                    principal.getUserId(),
                    request
            )
    );
}

@DeleteMapping("/{id}")
@PreAuthorize("hasRole('OWNER')")
public ResponseEntity<Void> deleteProperty(
        @PathVariable UUID id,
        Authentication authentication) {

    CustomUserPrincipal principal =
            (CustomUserPrincipal) authentication.getPrincipal();

    propertyService.deleteProperty(
            id,
            principal.getUserId()
    );

    return ResponseEntity.noContent().build();
}

@PutMapping("/{id}/approve")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<PropertyResponse> approveProperty(
        @PathVariable UUID id) {

    return ResponseEntity.ok(
            propertyService.approveProperty(id)
    );
}

@PutMapping("/{id}/reject")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<PropertyResponse> rejectProperty(
        @PathVariable UUID id) {

    return ResponseEntity.ok(
            propertyService.rejectProperty(id)
    );
}

@PutMapping("/{id}/publish")
@PreAuthorize("hasRole('OWNER')")
public ResponseEntity<PropertyResponse> publishProperty(
        @PathVariable UUID id,
        Authentication authentication) {

    CustomUserPrincipal principal =
            (CustomUserPrincipal) authentication.getPrincipal();

    return ResponseEntity.ok(
            propertyService.publishProperty(
                    id,
                    principal.getUserId()
            )
    );
}


}

