
package rental_platform_backend.tenant.controller;

import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.tenant.dto.TenantResponse;
import rental_platform_backend.tenant.service.TenantService;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/tenants")
public class TenantController {

    private final TenantService tenantService;

    public TenantController(TenantService tenantService) {
        this.tenantService = tenantService;
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public TenantResponse getMyTenant(Authentication authentication) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        return tenantService.getTenantByUserId(
                principal.getUserId()
        );
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'OWNER')")
    public TenantResponse getTenantById(
            @PathVariable UUID id) {

        return tenantService.getTenantById(id);
    }
}

