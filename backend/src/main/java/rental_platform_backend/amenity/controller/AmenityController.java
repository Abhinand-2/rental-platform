package rental_platform_backend.amenity.controller;

import rental_platform_backend.amenity.dto.AmenityResponse;
import rental_platform_backend.amenity.dto.CreateAmenityRequest;
import rental_platform_backend.amenity.service.AmenityService;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/amenities")
public class AmenityController {

    private final AmenityService amenityService;

    public AmenityController(AmenityService amenityService) {
        this.amenityService = amenityService;
    }

    // =========================
    // PUBLIC
    // =========================

    @GetMapping
    public List<AmenityResponse> getAllAmenities() {
        return amenityService.getAllAmenities();
    }

    // =========================
    // ADMIN
    // =========================

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public AmenityResponse createAmenity(
            @Valid @RequestBody CreateAmenityRequest request
    ) {
        return amenityService.createAmenity(request);
    }

    @DeleteMapping("/{amenityId}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAmenity(
            @PathVariable UUID amenityId
    ) {
        amenityService.deleteAmenity(amenityId);
    }

    // =========================
    // PROPERTY AMENITIES
    // =========================

    @GetMapping("/property/{propertyId}")
    public List<AmenityResponse> getPropertyAmenities(
            @PathVariable UUID propertyId
    ) {
        return amenityService.getPropertyAmenities(propertyId);
    }

    @PostMapping("/property/{propertyId}/{amenityId}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addAmenityToProperty(
            @PathVariable UUID propertyId,
            @PathVariable UUID amenityId,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin = authentication.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals("ROLE_ADMIN"));

        amenityService.addAmenityToProperty(
                propertyId,
                amenityId,
                principal.getUserId(),
                isAdmin
        );
    }

    @DeleteMapping("/property/{propertyId}/{amenityId}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeAmenityFromProperty(
            @PathVariable UUID propertyId,
            @PathVariable UUID amenityId,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin = authentication.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals("ROLE_ADMIN"));

        amenityService.removeAmenityFromProperty(
                propertyId,
                amenityId,
                principal.getUserId(),
                isAdmin
        );
    }
}