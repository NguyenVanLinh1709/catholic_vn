package com.churchhub.config;

import com.churchhub.user.Role;
import com.churchhub.user.User;
import com.churchhub.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

/**
 * Ensures at least one SUPER_ADMIN exists. If none is present, creates one from
 * SUPERADMIN_EMAIL / SUPERADMIN_PASSWORD (BCrypt-hashed; never stored plaintext).
 * No-op if a SUPER_ADMIN already exists or no password is configured.
 */
@Component
@RequiredArgsConstructor
public class SuperAdminBootstrap implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(SuperAdminBootstrap.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.superadmin.email}")
    private String email;

    @Value("${app.superadmin.password}")
    private String password;

    @Value("${app.superadmin.full-name}")
    private String fullName;

    @Override
    @Transactional
    public void run(String... args) {
        if (userRepository.existsByRole(Role.SUPER_ADMIN)) {
            return;
        }
        if (!StringUtils.hasText(password)) {
            log.warn("No SUPER_ADMIN found and SUPERADMIN_PASSWORD is not set; "
                    + "skipping bootstrap. Set SUPERADMIN_EMAIL/SUPERADMIN_PASSWORD to auto-create one.");
            return;
        }
        if (userRepository.existsByEmail(email)) {
            log.warn("Cannot bootstrap SUPER_ADMIN: email {} already exists.", email);
            return;
        }

        User admin = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(password))
                .fullName(StringUtils.hasText(fullName) ? fullName : "Super Admin")
                .role(Role.SUPER_ADMIN)
                .parishId(null)
                .enabled(true)
                .build();
        userRepository.save(admin);
        log.info("Bootstrapped initial SUPER_ADMIN account: {}", email);
    }
}
