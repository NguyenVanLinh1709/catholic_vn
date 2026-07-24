package com.churchhub.registration;

import com.churchhub.common.ConflictException;
import com.churchhub.common.NotFoundException;
import com.churchhub.common.PageResponse;
import com.churchhub.parish.ParishRepository;
import com.churchhub.registration.dto.AdminRegistrationResponse;
import com.churchhub.registration.dto.ApproveRegistrationRequest;
import com.churchhub.registration.dto.RegisterAdminRequest;
import com.churchhub.registration.dto.RejectRegistrationRequest;
import com.churchhub.security.AuthUser;
import com.churchhub.security.SecurityUtils;
import com.churchhub.user.Role;
import com.churchhub.user.User;
import com.churchhub.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;

/**
 * Self-service PARISH_ADMIN sign-up: a person registers (PENDING), a
 * SUPER_ADMIN later approves (assigns a parish, creates the user account
 * from the registration's stored credentials) or rejects the request.
 */
@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final AdminRegistrationRepository registrationRepository;
    private final UserRepository userRepository;
    private final ParishRepository parishRepository;
    private final PasswordEncoder passwordEncoder;
    private final RegistrationRateLimiter rateLimiter;

    @Transactional
    public AdminRegistrationResponse register(RegisterAdminRequest request, String clientIp) {
        rateLimiter.checkAllowed(clientIp);

        String email = request.email();
        if (userRepository.existsByEmail(email)) {
            throw new ConflictException("Email already in use: " + email);
        }
        if (registrationRepository.existsByEmailIgnoreCaseAndStatus(email, RegistrationStatus.PENDING)) {
            throw new ConflictException("A pending registration already exists for: " + email);
        }

        AdminRegistration registration = AdminRegistration.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(request.password()))
                .fullName(request.fullName())
                .status(RegistrationStatus.PENDING)
                .build();
        try {
            // The existsByEmailIgnoreCaseAndStatus check above rules out the common case;
            // this only fires on a concurrent submission racing past it for the same email.
            return AdminRegistrationResponse.from(registrationRepository.save(registration));
        } catch (DataIntegrityViolationException ex) {
            throw new ConflictException("A pending registration already exists for: " + email);
        }
    }

    @Transactional(readOnly = true)
    public PageResponse<AdminRegistrationResponse> list(RegistrationStatus status, Pageable pageable) {
        Page<AdminRegistration> page = status != null
                ? registrationRepository.findByStatus(status, pageable)
                : registrationRepository.findAll(pageable);
        return PageResponse.from(page.map(AdminRegistrationResponse::from));
    }

    @Transactional(readOnly = true)
    public AdminRegistrationResponse get(Long id) {
        return AdminRegistrationResponse.from(getRegistration(id));
    }

    /** Creates the PARISH_ADMIN user from the registration's stored credentials. */
    @Transactional
    public AdminRegistrationResponse approve(Long id, ApproveRegistrationRequest request) {
        AdminRegistration registration = getRegistration(id);
        requirePending(registration);
        if (!parishRepository.existsById(request.parishId())) {
            throw NotFoundException.of("Parish", request.parishId());
        }
        if (userRepository.existsByEmail(registration.getEmail())) {
            throw new ConflictException("Email already in use: " + registration.getEmail());
        }

        User user = User.builder()
                .email(registration.getEmail())
                .passwordHash(registration.getPasswordHash())
                .fullName(registration.getFullName())
                .role(Role.PARISH_ADMIN)
                .parishId(request.parishId())
                .enabled(true)
                .build();
        User savedUser;
        try {
            // existsByEmail above already ruled out the common case; this only fires on a
            // concurrent user creation racing past that check for the same email.
            savedUser = userRepository.save(user);
        } catch (DataIntegrityViolationException ex) {
            throw new ConflictException("Email already in use: " + registration.getEmail());
        }

        AuthUser reviewer = SecurityUtils.requireCurrentUser();
        registration.setStatus(RegistrationStatus.APPROVED);
        registration.setReviewedBy(reviewer.getId());
        registration.setReviewedAt(OffsetDateTime.now());
        registration.setCreatedUserId(savedUser.getId());

        return AdminRegistrationResponse.from(registrationRepository.save(registration));
    }

    @Transactional
    public AdminRegistrationResponse reject(Long id, RejectRegistrationRequest request) {
        AdminRegistration registration = getRegistration(id);
        requirePending(registration);

        AuthUser reviewer = SecurityUtils.requireCurrentUser();
        registration.setStatus(RegistrationStatus.REJECTED);
        registration.setRejectReason(request.reason());
        registration.setReviewedBy(reviewer.getId());
        registration.setReviewedAt(OffsetDateTime.now());

        return AdminRegistrationResponse.from(registrationRepository.save(registration));
    }

    private AdminRegistration getRegistration(Long id) {
        return registrationRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("AdminRegistration", id));
    }

    private void requirePending(AdminRegistration registration) {
        if (registration.getStatus() != RegistrationStatus.PENDING) {
            throw new ConflictException("Registration " + registration.getId() + " has already been reviewed");
        }
    }
}
