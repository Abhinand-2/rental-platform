package rental_platform_backend.auth.service;

import rental_platform_backend.auth.dto.AuthResponse;
import rental_platform_backend.auth.dto.LoginRequest;
import rental_platform_backend.auth.dto.RefreshTokenRequest;
import rental_platform_backend.auth.dto.RegisterRequest;
import rental_platform_backend.auth.entity.RefreshToken;
import rental_platform_backend.auth.repository.RefreshTokenRepository;
import rental_platform_backend.auth.security.CustomUserPrincipal;
import rental_platform_backend.auth.security.JwtService;
import rental_platform_backend.user.entity.Role;
import rental_platform_backend.user.entity.User;
import rental_platform_backend.user.entity.UserStatus;
import rental_platform_backend.user.repository.UserRepository;
import rental_platform_backend.common.exception.DuplicateResourceException;
import rental_platform_backend.common.exception.ForbiddenOperationException;
import rental_platform_backend.common.exception.ResourceNotFoundException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;

@Service
public class AuthService {

    private static final long REFRESH_TOKEN_EXPIRATION_DAYS = 30;

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    private final SecureRandom secureRandom = new SecureRandom();

    public AuthService(
            UserRepository userRepository,
            RefreshTokenRepository refreshTokenRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtService jwtService
    ) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {

        String email = request.getEmail()
                .trim()
                .toLowerCase();

        if (userRepository.existsByEmail(email)) {
            throw new DuplicateResourceException(
                    "User with this email already exists"
            );
        }

        Role role = request.getRole();

        if (role == null) {
            role = Role.USER;
        }

        if (role == Role.ADMIN) {
            throw new ForbiddenOperationException(
                    "Admin accounts cannot be created through public registration"
            );
        }

        User user = new User();

        user.setEmail(email);
        user.setPasswordHash(
                passwordEncoder.encode(request.getPassword())
        );
        user.setFirstName(request.getFirstName().trim());
        user.setLastName(
                request.getLastName() == null
                        ? null
                        : request.getLastName().trim()
        );
        user.setPhone(
                request.getPhone() == null
                        ? null
                        : request.getPhone().trim()
        );
        user.setRole(role);
        user.setStatus(UserStatus.ACTIVE);

        User savedUser = userRepository.save(user);

        return createAuthenticationResponse(savedUser);
    }

    public AuthResponse login(LoginRequest request) {

        String email = request.getEmail()
                .trim()
                .toLowerCase();

        Authentication authentication =
                authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                email,
                                request.getPassword()
                        )
                );

        CustomUserPrincipal principal =
                (CustomUserPrincipal) authentication.getPrincipal();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new ResourceNotFoundException("User not found")
                );

        if (user.getStatus() != UserStatus.ACTIVE) {
            throw new ForbiddenOperationException(
                    "User account is not active"
            );
        }

        return createAuthenticationResponse(user, principal);
    }

    @Transactional
    public AuthResponse refresh(RefreshTokenRequest request) {

        String tokenHash = hashRefreshToken(
                request.getRefreshToken()
        );

        RefreshToken refreshToken =
                refreshTokenRepository.findByTokenHash(tokenHash)
                        .orElseThrow(() ->
                                new ForbiddenOperationException(
                                        "Invalid refresh token"
                                )
                        );

        if (refreshToken.isRevoked()) {
            throw new ForbiddenOperationException(
                    "Refresh token has been revoked"
            );
        }

        if (refreshToken.getExpiresAt()
                .isBefore(LocalDateTime.now())) {

            refreshToken.setRevoked(true);

            throw new ForbiddenOperationException(
                    "Refresh token has expired"
            );
        }

        User user = refreshToken.getUser();

        if (user.getStatus() != UserStatus.ACTIVE) {

            refreshToken.setRevoked(true);

            throw new ForbiddenOperationException(
                    "User account is not active"
            );
        }

        /*
         * Refresh-token rotation:
         *
         * Old refresh token becomes invalid.
         * New refresh token is issued.
         */
        refreshToken.setRevoked(true);

        CustomUserPrincipal principal =
                new CustomUserPrincipal(user);

        String accessToken =
                jwtService.generateAccessToken(principal);

        String newRefreshToken =
                generateRefreshToken();

        saveRefreshToken(user, newRefreshToken);

        return new AuthResponse(
                accessToken,
                newRefreshToken,
                "Bearer",
                jwtService.getAccessTokenExpiration()
        );
    }

    @Transactional
    public void logout(String refreshTokenValue) {

        String tokenHash =
                hashRefreshToken(refreshTokenValue);

        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(token -> {
                    token.setRevoked(true);
                    refreshTokenRepository.save(token);
                });
    }

    private AuthResponse createAuthenticationResponse(User user) {

        CustomUserPrincipal principal =
                new CustomUserPrincipal(user);

        return createAuthenticationResponse(user, principal);
    }

    private AuthResponse createAuthenticationResponse(
            User user,
            CustomUserPrincipal principal
    ) {

        String accessToken =
                jwtService.generateAccessToken(principal);

        String refreshToken =
                generateRefreshToken();

        saveRefreshToken(user, refreshToken);

        return new AuthResponse(
                accessToken,
                refreshToken,
                "Bearer",
                jwtService.getAccessTokenExpiration()
        );
    }

    private String generateRefreshToken() {

        byte[] randomBytes = new byte[64];

        secureRandom.nextBytes(randomBytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes);
    }

    private void saveRefreshToken(
            User user,
            String rawToken
    ) {

        RefreshToken refreshToken =
                new RefreshToken();

        refreshToken.setUser(user);

        refreshToken.setTokenHash(
                hashRefreshToken(rawToken)
        );

        refreshToken.setExpiresAt(
                LocalDateTime.now()
                        .plusDays(REFRESH_TOKEN_EXPIRATION_DAYS)
        );

        refreshToken.setRevoked(false);

        refreshTokenRepository.save(refreshToken);
    }

    private String hashRefreshToken(String token) {

        try {

            java.security.MessageDigest digest =
                    java.security.MessageDigest.getInstance("SHA-256");

            byte[] hash =
                    digest.digest(
                            token.getBytes(
                                    java.nio.charset.StandardCharsets.UTF_8
                            )
                    );

            return java.util.HexFormat.of()
                    .formatHex(hash);

        } catch (java.security.NoSuchAlgorithmException exception) {

            throw new IllegalStateException(
                    "SHA-256 algorithm is unavailable",
                    exception
            );
        }
    }
}