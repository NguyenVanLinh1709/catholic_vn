package com.churchhub.parish;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ParishRepository extends JpaRepository<Parish, Long> {

    Optional<Parish> findBySlug(String slug);

    boolean existsBySlug(String slug);

    Page<Parish> findByNameContainingIgnoreCase(String name, Pageable pageable);
}
