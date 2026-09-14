package rental_platform_backend.dashboard.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.dashboard.dto.AdminUserResponse;
import rental_platform_backend.dashboard.dto.UpdateUserStatusRequest;
import rental_platform_backend.dashboard.service.AdminUserService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public class AdminUserController {

    private final AdminUserService adminUserService;

    public AdminUserController(
            AdminUserService adminUserService
    ) {
        this.adminUserService = adminUserService;
    }

    @GetMapping
    public List<AdminUserResponse> getAllUsers() {

        return adminUserService.getAllUsers();
    }

    @GetMapping("/{id}")
    public AdminUserResponse getUser(
            @PathVariable UUID id
    ) {

        return adminUserService.getUser(id);
    }

    @PutMapping("/{id}/status")
    public AdminUserResponse updateUserStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateUserStatusRequest request,
            Authentication authentication
    ) {

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        return adminUserService.updateUserStatus(
                id,
                request.status(),
                principal.getUserId()
        );
    }
}