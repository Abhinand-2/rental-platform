package rental_platform_backend.dashboard.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.dashboard.dto.AdminUserResponse;
import rental_platform_backend.dashboard.dto.UpdateUserStatusRequest;
import rental_platform_backend.user.entity.Role;
import rental_platform_backend.user.entity.User;
import rental_platform_backend.user.entity.UserStatus;
import rental_platform_backend.user.repository.UserRepository;

import java.util.List;
import java.util.UUID;

@Service
public class AdminUserService {

    private final UserRepository userRepository;

    public AdminUserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminUserResponse> getAllUsers() {

        return userRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public AdminUserResponse getUser(UUID userId) {

        User user = getUserEntity(userId);

        return toResponse(user);
    }

    @Transactional
    public AdminUserResponse updateUserStatus(
            UUID userId,
            UserStatus newStatus,
            UUID adminUserId
    ) {

        if (userId.equals(adminUserId)) {
            throw new IllegalArgumentException(
                    "An administrator cannot change their own account status"
            );
        }

        User user = getUserEntity(userId);

        if (user.getRole() == null) {
            throw new IllegalStateException(
                    "User role is not configured"
            );
        }

        if (user.getRole() == Role.ADMIN) {
            throw new IllegalArgumentException(
                    "Administrator account status cannot be changed here"
            );
        }

        user.setStatus(newStatus);

        User savedUser = userRepository.save(user);

        return toResponse(savedUser);
    }

    private User getUserEntity(UUID userId) {

        return userRepository.findById(userId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "User not found"
                        )
                );
    }

    private AdminUserResponse toResponse(User user) {

        String fullName =
                ((user.getFirstName() == null)
                        ? ""
                        : user.getFirstName().trim())
                + " "
                + ((user.getLastName() == null)
                        ? ""
                        : user.getLastName().trim());

        fullName = fullName.trim();

        return new AdminUserResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                fullName,
                user.getEmail(),
                user.getPhone(),
                user.getRole(),
                user.getStatus(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}