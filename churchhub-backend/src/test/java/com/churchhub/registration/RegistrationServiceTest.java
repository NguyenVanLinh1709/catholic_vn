package com.churchhub.registration;

import com.churchhub.common.ConflictException;
import com.churchhub.common.NotFoundException;
import com.churchhub.common.TooManyRequestsException;
import com.churchhub.parish.ParishRepository;
import com.churchhub.registration.dto.AdminRegistrationResponse;
import com.churchhub.registration.dto.ApproveRegistrationRequest;
import com.churchhub.registration.dto.RegisterAdminRequest;
import com.churchhub.registration.dto.RejectRegistrationRequest;
import com.churchhub.security.AuthUser;
import com.churchhub.user.Role;
import com.churchhub.user.User;
import com.churchhub.user.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RegistrationServiceTest {

    @Mock
    private AdminRegistrationRepository registrationRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private ParishRepository parishRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private RegistrationRateLimiter rateLimiter;

    private RegistrationService service;

    private void init() {
        service = new RegistrationService(registrationRepository, userRepository, parishRepository,
                passwordEncoder, rateLimiter);
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void registerEnforcesRateLimitBeforeTouchingRepositories() {
        init();
        doThrow(new TooManyRequestsException("slow down")).when(rateLimiter).checkAllowed("1.2.3.4");
        RegisterAdminRequest request = new RegisterAdminRequest("any@test.com", "password123", "Name");

        assertThatThrownBy(() -> service.register(request, "1.2.3.4")).isInstanceOf(TooManyRequestsException.class);
        verifyNoInteractions(userRepository, registrationRepository);
    }

    @Test
    void registerRejectsWhenEmailAlreadyHasAnAccount() {
        init();
        when(userRepository.existsByEmail("taken@test.com")).thenReturn(true);
        RegisterAdminRequest request = new RegisterAdminRequest("taken@test.com", "password123", "Name");

        assertThatThrownBy(() -> service.register(request, "127.0.0.1")).isInstanceOf(ConflictException.class);
        verify(registrationRepository, never()).save(any());
    }

    @Test
    void registerRejectsWhenAPendingRequestAlreadyExists() {
        init();
        when(userRepository.existsByEmail("pending@test.com")).thenReturn(false);
        when(registrationRepository.existsByEmailIgnoreCaseAndStatus("pending@test.com", RegistrationStatus.PENDING))
                .thenReturn(true);
        RegisterAdminRequest request = new RegisterAdminRequest("pending@test.com", "password123", "Name");

        assertThatThrownBy(() -> service.register(request, "127.0.0.1")).isInstanceOf(ConflictException.class);
    }

    @Test
    void registerSucceedsAndStoresAPendingRegistration() {
        init();
        when(userRepository.existsByEmail("new@test.com")).thenReturn(false);
        when(registrationRepository.existsByEmailIgnoreCaseAndStatus(eq("new@test.com"), eq(RegistrationStatus.PENDING)))
                .thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("hashed");
        when(registrationRepository.save(any(AdminRegistration.class))).thenAnswer(inv -> inv.getArgument(0));

        RegisterAdminRequest request = new RegisterAdminRequest("new@test.com", "password123", "New Person");
        AdminRegistrationResponse response = service.register(request, "127.0.0.1");

        assertThat(response.email()).isEqualTo("new@test.com");
        assertThat(response.status()).isEqualTo(RegistrationStatus.PENDING);
    }

    @Test
    void approveRejectsWhenRegistrationIsNotPending() {
        init();
        setCurrentReviewer(1L);
        when(registrationRepository.findById(10L)).thenReturn(Optional.of(registration(10L, RegistrationStatus.APPROVED)));

        assertThatThrownBy(() -> service.approve(10L, new ApproveRegistrationRequest(1L)))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void approveRejectsWhenParishDoesNotExist() {
        init();
        setCurrentReviewer(1L);
        when(registrationRepository.findById(10L)).thenReturn(Optional.of(registration(10L, RegistrationStatus.PENDING)));
        when(parishRepository.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> service.approve(10L, new ApproveRegistrationRequest(99L)))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    void approveCreatesTheParishAdminAndMarksRegistrationApproved() {
        init();
        setCurrentReviewer(1L);
        AdminRegistration registration = registration(10L, RegistrationStatus.PENDING);
        when(registrationRepository.findById(10L)).thenReturn(Optional.of(registration));
        when(parishRepository.existsById(5L)).thenReturn(true);
        when(userRepository.existsByEmail(registration.getEmail())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            User saved = inv.getArgument(0);
            saved.setId(42L);
            return saved;
        });
        when(registrationRepository.save(any(AdminRegistration.class))).thenAnswer(inv -> inv.getArgument(0));

        AdminRegistrationResponse response = service.approve(10L, new ApproveRegistrationRequest(5L));

        assertThat(response.status()).isEqualTo(RegistrationStatus.APPROVED);
        assertThat(response.createdUserId()).isEqualTo(42L);
        verify(userRepository).save(argThat(u -> u.getRole() == Role.PARISH_ADMIN && Long.valueOf(5L).equals(u.getParishId())));
    }

    @Test
    void rejectRejectsWhenRegistrationIsNotPending() {
        init();
        setCurrentReviewer(1L);
        when(registrationRepository.findById(11L)).thenReturn(Optional.of(registration(11L, RegistrationStatus.REJECTED)));

        assertThatThrownBy(() -> service.reject(11L, new RejectRegistrationRequest("dup")))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void rejectMarksRegistrationRejectedWithReason() {
        init();
        setCurrentReviewer(1L);
        when(registrationRepository.findById(11L)).thenReturn(Optional.of(registration(11L, RegistrationStatus.PENDING)));
        when(registrationRepository.save(any(AdminRegistration.class))).thenAnswer(inv -> inv.getArgument(0));

        AdminRegistrationResponse response = service.reject(11L, new RejectRegistrationRequest("not a fit"));

        assertThat(response.status()).isEqualTo(RegistrationStatus.REJECTED);
        assertThat(response.rejectReason()).isEqualTo("not a fit");
    }

    private AdminRegistration registration(Long id, RegistrationStatus status) {
        return AdminRegistration.builder()
                .id(id)
                .email("reg" + id + "@test.com")
                .passwordHash("hash")
                .fullName("Registrant " + id)
                .status(status)
                .build();
    }

    private void setCurrentReviewer(Long id) {
        AuthUser reviewer = new AuthUser(id, "reviewer@test.com", "hash", Role.SUPER_ADMIN, null, true, 0);
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(reviewer, null, reviewer.getAuthorities()));
    }
}
