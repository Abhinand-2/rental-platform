package rental_platform_backend.propertyimage.controller;

import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.propertyimage.dto.CreatePropertyImageRequest;
import rental_platform_backend.propertyimage.dto.PropertyImageResponse;
import rental_platform_backend.propertyimage.service.PropertyImageService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/properties/{propertyId}/images")
public class PropertyImageController {

    private final PropertyImageService propertyImageService;

    public PropertyImageController(
            PropertyImageService propertyImageService
    ) {
        this.propertyImageService = propertyImageService;
    }

    @GetMapping
    public List<PropertyImageResponse> getImages(
            @PathVariable UUID propertyId
    ) {
        return propertyImageService.getImages(propertyId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public PropertyImageResponse addImage(
            @PathVariable UUID propertyId,
            @Valid @RequestBody CreatePropertyImageRequest request,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                authentication.getAuthorities()
                        .stream()
                        .anyMatch(
                                authority ->
                                        authority.getAuthority()
                                                .equals("ROLE_ADMIN")
                        );

        return propertyImageService.addImage(
                propertyId,
                principal.getUserId(),
                request,
                isAdmin
        );
    }

    @DeleteMapping("/{imageId}")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteImage(
            @PathVariable UUID propertyId,
            @PathVariable UUID imageId,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                authentication.getAuthorities()
                        .stream()
                        .anyMatch(
                                authority ->
                                        authority.getAuthority()
                                                .equals("ROLE_ADMIN")
                        );

        propertyImageService.deleteImage(
                propertyId,
                imageId,
                principal.getUserId(),
                isAdmin
        );
    }

    @PutMapping("/{imageId}/primary")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public PropertyImageResponse setPrimary(
            @PathVariable UUID propertyId,
            @PathVariable UUID imageId,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                authentication.getAuthorities()
                        .stream()
                        .anyMatch(
                                authority ->
                                        authority.getAuthority()
                                                .equals("ROLE_ADMIN")
                        );

        return propertyImageService.setPrimary(
                propertyId,
                imageId,
                principal.getUserId(),
                isAdmin
        );
    }
}