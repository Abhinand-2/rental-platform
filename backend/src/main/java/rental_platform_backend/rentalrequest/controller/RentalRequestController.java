package rental_platform_backend.rentalrequest.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.rentalrequest.dto.CreateRentalRequest;
import rental_platform_backend.rentalrequest.dto.RentalRequestResponse;
import rental_platform_backend.rentalrequest.service.RentalRequestService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/rental-requests")
public class RentalRequestController {

    private final RentalRequestService rentalRequestService;

    public RentalRequestController(
            RentalRequestService rentalRequestService
    ) {
        this.rentalRequestService = rentalRequestService;
    }

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    @ResponseStatus(HttpStatus.CREATED)
    public RentalRequestResponse createRequest(
            @Valid @RequestBody CreateRentalRequest request,
            Authentication authentication
    ) {

        UUID userId = getAuthenticatedUserId(authentication);

        return rentalRequestService.createRequest(
                request,
                userId
        );
    }

    @GetMapping("/{id}")
    public RentalRequestResponse getRequest(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        UUID userId = getAuthenticatedUserId(authentication);

        return rentalRequestService.getRequest(
                id,
                userId
        );
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public List<RentalRequestResponse> getMyRequests(
            Authentication authentication
    ) {

        UUID userId = getAuthenticatedUserId(authentication);

        return rentalRequestService.getMyRequests(userId);
    }

    @GetMapping("/owner")
    @PreAuthorize("hasRole('OWNER')")
    public List<RentalRequestResponse> getOwnerRequests(
            Authentication authentication
    ) {

        UUID ownerId = getAuthenticatedUserId(authentication);

        return rentalRequestService.getOwnerRequests(ownerId);
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public List<RentalRequestResponse> getAllRequests() {

        return rentalRequestService.getAllRequests();
    }

    @PutMapping("/{id}/approve")
    @PreAuthorize("hasRole('OWNER')")
    public RentalRequestResponse approveRequest(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        UUID ownerId = getAuthenticatedUserId(authentication);

        return rentalRequestService.approveRequest(
                id,
                ownerId
        );
    }

    @PutMapping("/{id}/reject")
    @PreAuthorize("hasRole('OWNER')")
    public RentalRequestResponse rejectRequest(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        UUID ownerId = getAuthenticatedUserId(authentication);

        return rentalRequestService.rejectRequest(
                id,
                ownerId
        );
    }

    @PutMapping("/{id}/cancel")
    @PreAuthorize("hasRole('USER')")
    public RentalRequestResponse cancelRequest(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        UUID applicantId = getAuthenticatedUserId(authentication);

        return rentalRequestService.cancelRequest(
                id,
                applicantId
        );
    }

    private UUID getAuthenticatedUserId(
            Authentication authentication
    ) {

        CustomUserPrincipal userPrincipal =
                (CustomUserPrincipal) authentication.getPrincipal();

        return userPrincipal.getUserId();
    }
}