
package rental_platform_backend.tenant.service;

import rental_platform_backend.common.exception.ResourceNotFoundException;
import rental_platform_backend.tenant.dto.TenantResponse;
import rental_platform_backend.tenant.entity.Tenant;
import rental_platform_backend.tenant.repository.TenantRepository;
import rental_platform_backend.user.entity.User;
import rental_platform_backend.user.repository.UserRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class TenantService {

    private final TenantRepository tenantRepository;
    private final UserRepository userRepository;

    public TenantService(
            TenantRepository tenantRepository,
            UserRepository userRepository) {

        this.tenantRepository = tenantRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public TenantResponse createTenant(UUID userId) {

        if (tenantRepository.existsByUserId(userId)) {
            return toResponse(
                    tenantRepository.findByUserId(userId)
                            .orElseThrow(() ->
                                    new ResourceNotFoundException(
                                            "Tenant not found"))
            );
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "User not found with id: " + userId));

        Tenant tenant = new Tenant();
        tenant.setUser(user);

        Tenant savedTenant = tenantRepository.save(tenant);

        return toResponse(savedTenant);
    }

    @Transactional(readOnly = true)
    public TenantResponse getTenantById(UUID tenantId) {

        Tenant tenant = tenantRepository.findById(tenantId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Tenant not found with id: " + tenantId));

        return toResponse(tenant);
    }

    @Transactional(readOnly = true)
    public TenantResponse getTenantByUserId(UUID userId) {

        Tenant tenant = tenantRepository.findByUserId(userId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Tenant not found for user: " + userId));

        return toResponse(tenant);
    }
    @Transactional(readOnly = true)
public Tenant getTenantEntityByUserId(UUID userId) {
    return tenantRepository.findByUserId(userId)
            .orElseThrow(() ->
                    new ResourceNotFoundException("Tenant not found")
            );
}
    private TenantResponse toResponse(Tenant tenant) {

        return new TenantResponse(
                tenant.getId(),
                tenant.getUser().getId(),
                tenant.getCreatedAt(),
                tenant.getUpdatedAt()
        );
    }
}

