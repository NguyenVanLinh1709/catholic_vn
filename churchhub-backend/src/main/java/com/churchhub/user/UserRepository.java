package com.churchhub.user;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    List<User> findByParishIdAndRole(Long parishId, Role role);

    boolean existsByEmail(String email);

    boolean existsByRole(Role role);

    Optional<User> findFirstByRole(Role role);
}
