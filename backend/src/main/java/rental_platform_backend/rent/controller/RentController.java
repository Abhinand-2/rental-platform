package rental_platform_backend.rent.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.rent.dto.CreateRentChargeRequest;
import rental_platform_backend.rent.dto.RecordRentPaymentRequest;
import rental_platform_backend.rent.dto.RentChargeResponse;
import rental_platform_backend.rent.dto.RentPaymentResponse;
import rental_platform_backend.rent.service.RentService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/rent")
public class RentController {

    private final RentService rentService;

    public RentController(RentService rentService) {
        this.rentService = rentService;
    }

    // =========================================================
    // RENT CHARGES
    // =========================================================

    @PostMapping("/charges")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public RentChargeResponse createRentCharge(
            @Valid @RequestBody CreateRentChargeRequest request,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.createRentCharge(
                request,
                principal.getUserId(),
                isAdmin(principal)
        );
    }

    @GetMapping("/charges/{id}")
    public RentChargeResponse getRentCharge(
            @PathVariable UUID id,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getRentCharge(
                id,
                principal.getUserId(),
                isAdmin(principal)
        );
    }

    @GetMapping("/charges/my")
    @PreAuthorize("hasRole('USER')")
    public List<RentChargeResponse> getMyRentCharges(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getMyCharges(
                principal.getUserId()
        );
    }

    @GetMapping("/charges/owner")
    @PreAuthorize("hasRole('OWNER')")
    public List<RentChargeResponse> getOwnerRentCharges(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getOwnerCharges(
                principal.getUserId()
        );
    }

    @GetMapping("/charges/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public List<RentChargeResponse> getAllRentCharges() {

        return rentService.getAllCharges();
    }

    // =========================================================
    // RENT PAYMENTS
    // =========================================================

    @PostMapping("/payments")
    @PreAuthorize("hasAnyRole('OWNER', 'ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public RentPaymentResponse recordPayment(
            @Valid @RequestBody RecordRentPaymentRequest request,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.recordPayment(
                request,
                principal.getUserId(),
                isAdmin(principal)
        );
    }

    @GetMapping("/payments/charge/{chargeId}")
    public RentPaymentResponse getPaymentByCharge(
            @PathVariable UUID chargeId,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getPaymentByCharge(
                chargeId,
                principal.getUserId(),
                isAdmin(principal)
        );
    }

    @GetMapping("/payments/my")
    @PreAuthorize("hasRole('USER')")
    public List<RentPaymentResponse> getMyPayments(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getMyPayments(
                principal.getUserId()
        );
    }

    @GetMapping("/payments/owner")
    @PreAuthorize("hasRole('OWNER')")
    public List<RentPaymentResponse> getOwnerPayments(
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                getPrincipal(authentication);

        return rentService.getOwnerPayments(
                principal.getUserId()
        );
    }

    // =========================================================
    // HELPERS
    // =========================================================

    private CustomUserPrincipal getPrincipal(
            Authentication authentication
    ) {

        return (CustomUserPrincipal) authentication.getPrincipal();
    }

    private boolean isAdmin(
            CustomUserPrincipal principal
    ) {

        return principal.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals("ROLE_ADMIN")
                );
    }
}