package com.churchhub.user;

import com.churchhub.common.ConflictException;
import com.churchhub.parish.ParishRepository;
import com.churchhub.security.AuthUser;
import com.churchhub.user.dto.CreateUserRequest;
import com.churchhub.user.dto.UpdateUserRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private ParishRepository parishRepository;
    @Mock
    private PasswordEncoder passwordEncoder;

    private UserService userService;

    private void init() {
        userService = new UserService(userRepository, parishRepository, passwordEncoder);
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void deleteRejectsDeletingOwnAccount() {
        init();
        setCurrentUser(5L, Role.SUPER_ADMIN);
        when(userRepository.findById(5L)).thenReturn(Optional.of(user(5L, Role.SUPER_ADMIN)));

        assertThatThrownBy(() -> userService.delete(5L)).isInstanceOf(ConflictException.class);
        verify(userRepository, never()).delete(any());
    }

    @Test
    void deleteRejectsDeletingTheSuperAdmin() {
        init();
        setCurrentUser(99L, Role.SUPER_ADMIN);
        when(userRepository.findById(7L)).thenReturn(Optional.of(user(7L, Role.SUPER_ADMIN)));

        assertThatThrownBy(() -> userService.delete(7L)).isInstanceOf(ConflictException.class);
        verify(userRepository, never()).delete(any());
    }

    @Test
    void deleteSucceedsForAnotherParishAdmin() {
        init();
        setCurrentUser(99L, Role.SUPER_ADMIN);
        User target = user(7L, Role.PARISH_ADMIN);
        when(userRepository.findById(7L)).thenReturn(Optional.of(target));

        assertThatCode(() -> userService.delete(7L)).doesNotThrowAnyException();
        verify(userRepository).delete(target);
    }

    @Test
    void updateRejectsChangingOwnRole() {
        init();
        setCurrentUser(5L, Role.SUPER_ADMIN);
        when(userRepository.findById(5L)).thenReturn(Optional.of(user(5L, Role.SUPER_ADMIN)));

        UpdateUserRequest request = new UpdateUserRequest(null, Role.PARISH_ADMIN, null, null, null);

        assertThatThrownBy(() -> userService.update(5L, request)).isInstanceOf(ConflictException.class);
    }

    @Test
    void updateRejectsDisablingOwnAccount() {
        init();
        setCurrentUser(5L, Role.SUPER_ADMIN);
        when(userRepository.findById(5L)).thenReturn(Optional.of(user(5L, Role.SUPER_ADMIN)));

        UpdateUserRequest request = new UpdateUserRequest(null, null, null, false, null);

        assertThatThrownBy(() -> userService.update(5L, request)).isInstanceOf(ConflictException.class);
    }

    @Test
    void createRejectsSecondSuperAdmin() {
        init();
        when(userRepository.existsByEmail("new@test.com")).thenReturn(false);
        when(userRepository.findFirstByRole(Role.SUPER_ADMIN))
                .thenReturn(Optional.of(user(1L, Role.SUPER_ADMIN)));

        CreateUserRequest request =
                new CreateUserRequest("new@test.com", "password123", "New Admin", Role.SUPER_ADMIN, null);

        assertThatThrownBy(() -> userService.create(request)).isInstanceOf(ConflictException.class);
    }

    @Test
    void createTurnsConcurrentDuplicateEmailIntoConflict() {
        init();
        when(userRepository.existsByEmail("race@test.com")).thenReturn(false);
        when(passwordEncoder.encode(any())).thenReturn("hashed");
        when(userRepository.save(any(User.class))).thenThrow(new DataIntegrityViolationException("dup email"));

        CreateUserRequest request =
                new CreateUserRequest("race@test.com", "password123", "Racer", Role.PARISH_ADMIN, null);

        assertThatThrownBy(() -> userService.create(request)).isInstanceOf(ConflictException.class);
    }

    private User user(Long id, Role role) {
        return User.builder()
                .id(id)
                .email("user" + id + "@test.com")
                .passwordHash("hash")
                .fullName("User " + id)
                .role(role)
                .parishId(role == Role.PARISH_ADMIN ? 1L : null)
                .enabled(true)
                .build();
    }

    private void setCurrentUser(Long id, Role role) {
        AuthUser authUser = new AuthUser(id, "user" + id + "@test.com", "hash", role, null, true, 0);
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(authUser, null, authUser.getAuthorities()));
    }
}
