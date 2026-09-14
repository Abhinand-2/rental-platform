package rental_platform_backend.user.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import rental_platform_backend.user.entity.User;

import java.util.UUID;
import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, UUID> {

     boolean existsByEmail(String email);

    Optional<User> findByEmail(String email);
    List<User> findAllByOrderByCreatedAtDesc();
}