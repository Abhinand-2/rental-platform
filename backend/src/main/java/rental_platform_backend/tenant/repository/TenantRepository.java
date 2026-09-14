
package rental_platform_backend.tenant.repository;

import rental_platform_backend.tenant.entity.Tenant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface TenantRepository extends JpaRepository<Tenant, UUID> {

    Optional<Tenant> findByUserId(UUID userId);

    boolean existsByUserId(UUID userId);
}

