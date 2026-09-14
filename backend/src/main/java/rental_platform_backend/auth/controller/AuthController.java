package rental_platform_backend.auth.controller;

import org.springframework.security.core.Authentication;

import rental_platform_backend.auth.dto.AuthResponse;
import rental_platform_backend.auth.dto.LoginRequest;
import rental_platform_backend.auth.dto.RefreshTokenRequest;
import rental_platform_backend.auth.dto.RegisterRequest;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.auth.service.AuthService;
import rental_platform_backend.user.dto.UserResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import rental_platform_backend.user.service.UserService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final UserService userService;

    public AuthController(
        AuthService authService,
        UserService userService
) {
    this.authService = authService;
    this.userService = userService;
}

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {

        AuthResponse response =
                authService.register(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {

        AuthResponse response =
                authService.login(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(
            @Valid @RequestBody RefreshTokenRequest request
    ) {

        AuthResponse response =
                authService.refresh(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @Valid @RequestBody RefreshTokenRequest request
    ) {

        authService.logout(
                request.getRefreshToken()
        );

        return ResponseEntity.noContent().build();
    }
    @GetMapping("/me")
public UserResponse getCurrentUser(Authentication authentication) {

    CustomUserPrincipal principal =
            (CustomUserPrincipal) authentication.getPrincipal();

    return userService.getUserById(principal.getUserId());
}
}
