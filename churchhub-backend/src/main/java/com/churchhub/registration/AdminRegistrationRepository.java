package com.churchhub.registration;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminRegistrationRepository extends JpaRepository<AdminRegistration, Long> {

    Page<AdminRegistration> findByStatus(RegistrationStatus status, Pageable pageable);

    boolean existsByEmailIgnoreCaseAndStatus(String email, RegistrationStatus status);
}
