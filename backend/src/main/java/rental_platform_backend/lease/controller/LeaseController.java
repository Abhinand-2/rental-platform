
package rental_platform_backend.lease.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.lease.dto.CreateLeaseRequest;
import rental_platform_backend.lease.dto.LeaseResponse;
import rental_platform_backend.lease.service.LeaseService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/leases")
public class LeaseController {

    private final LeaseService leaseService;

    public LeaseController(LeaseService leaseService) {
        this.leaseService = leaseService;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public LeaseResponse createLease(
            @Valid @RequestBody CreateLeaseRequest request,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                principal.getAuthorities()
                        .stream()
                        .anyMatch(authority ->
                                authority.getAuthority()
                                        .equals("ROLE_ADMIN")
                        );

        return leaseService.createLease(
                request,
                principal.getUserId(),
                isAdmin
        );
    }

    @GetMapping("/{id}")
    public LeaseResponse getLease(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                principal.getAuthorities()
                        .stream()
                        .anyMatch(authority ->
                                authority.getAuthority()
                                        .equals("ROLE_ADMIN")
                        );

        return leaseService.getLeaseById(
                id,
                principal.getUserId(),
                isAdmin
        );
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public List<LeaseResponse> getMyLeases(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        return leaseService.getMyLeases(
                principal.getUserId()
        );
    }

    @GetMapping("/owner")
    @PreAuthorize("hasRole('OWNER')")
    public List<LeaseResponse> getOwnerLeases(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        return leaseService.getOwnerLeases(
                principal.getUserId()
        );
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public List<LeaseResponse> getAllLeases() {

        return leaseService.getAllLeases();
    }

    @PutMapping("/{id}/terminate")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public LeaseResponse terminateLease(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                principal.getAuthorities()
                        .stream()
                        .anyMatch(authority ->
                                authority.getAuthority()
                                        .equals("ROLE_ADMIN")
                        );

        return leaseService.terminateLease(
                id,
                principal.getUserId(),
                isAdmin
        );
    }

    @PutMapping("/{id}/cancel")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    public LeaseResponse cancelLease(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        boolean isAdmin =
                principal.getAuthorities()
                        .stream()
                        .anyMatch(authority ->
                                authority.getAuthority()
                                        .equals("ROLE_ADMIN")
                        );

        return leaseService.cancelLease(
                id,
                principal.getUserId(),
                isAdmin
        );
    }
}

