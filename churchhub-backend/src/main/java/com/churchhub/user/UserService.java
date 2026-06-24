package com.churchhub.user;

import com.churchhub.common.BadRequestException;
import com.churchhub.common.ConflictException;
import com.churchhub.common.NotFoundException;
import com.churchhub.common.PageResponse;
import com.churchhub.parish.ParishRepository;
import com.churchhub.user.dto.CreateUserRequest;
import com.churchhub.user.dto.UpdateUserRequest;
import com.churchhub.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final ParishRepository parishRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> list(Pageable pageable) {
        return PageResponse.from(userRepository.findAll(pageable).map(UserResponse::from));
    }

    @Transactional(readOnly = true)
    public UserResponse get(Long id) {
        return UserResponse.from(getUser(id));
    }

    @Transactional
    public UserResponse create(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new ConflictException("Email already in use: " + request.email());
        }
        assertSingleSuperAdmin(request.role(), null);
        Long parishId = normalizeParish(request.role(), request.parishId());

        User user = User.builder()
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .fullName(request.fullName())
                .role(request.role())
                .parishId(parishId)
                .enabled(true)
                .build();
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public UserResponse update(Long id, UpdateUserRequest request) {
        User user = getUser(id);

        if (StringUtils.hasText(request.fullName())) {
            user.setFullName(request.fullName());
        }
        Role role = request.role() != null ? request.role() : user.getRole();
        assertSingleSuperAdmin(role, user.getId());
        Long parishId = request.role() != null || request.parishId() != null
                ? normalizeParish(role, request.parishId() != null ? request.parishId() : user.getParishId())
                : user.getParishId();
        user.setRole(role);
        user.setParishId(parishId);

        if (request.enabled() != null) {
            user.setEnabled(request.enabled());
        }
        if (StringUtils.hasText(request.password())) {
            user.setPasswordHash(passwordEncoder.encode(request.password()));
        }
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public void delete(Long id) {
        User user = getUser(id);
        userRepository.delete(user);
    }

    private User getUser(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("User", id));
    }

    /**
     * Enforces the single-SUPER_ADMIN invariant: the system has exactly one super admin
     * (bootstrap-managed), so the API never creates or promotes a second one. {@code selfId}
     * is the user being updated (null on create) — a user already holding the role is exempt.
     */
    private void assertSingleSuperAdmin(Role role, Long selfId) {
        if (role != Role.SUPER_ADMIN) {
            return;
        }
        boolean otherSuperAdminExists = userRepository.findFirstByRole(Role.SUPER_ADMIN)
                .filter(existing -> !existing.getId().equals(selfId))
                .isPresent();
        if (otherSuperAdminExists) {
            throw new ConflictException("A SUPER_ADMIN account already exists; only one is allowed");
        }
    }

    /**
     * Enforces the role/parish invariant mirrored in the DB CHECK constraint:
     * a PARISH_ADMIN may reference an existing parish or be temporarily unassigned
     * (null); SUPER_ADMIN must never be tied to a parish.
     */
    private Long normalizeParish(Role role, Long parishId) {
        if (role == Role.PARISH_ADMIN) {
            if (parishId != null && !parishRepository.existsById(parishId)) {
                throw NotFoundException.of("Parish", parishId);
            }
            return parishId;
        }
        // SUPER_ADMIN must not be tied to a parish.
        return null;
    }

    @Transactional(readOnly = true)
    public List<UserResponse> listAdminsByParish(Long parishId) {
        if (!parishRepository.existsById(parishId)) {
            throw NotFoundException.of("Parish", parishId);
        }
        return userRepository.findByParishIdAndRole(parishId, Role.PARISH_ADMIN).stream()
                .map(UserResponse::from)
                .toList();
    }

    /**
     * Sets the exact set of PARISH_ADMIN accounts managing a parish. Users in
     * {@code userIds} are assigned to the parish; users currently assigned but not
     * listed are unassigned (parish_id -> null). Only PARISH_ADMIN accounts are accepted.
     */
    @Transactional
    public List<UserResponse> setParishAdmins(Long parishId, List<Long> userIds) {
        if (!parishRepository.existsById(parishId)) {
            throw NotFoundException.of("Parish", parishId);
        }
        List<Long> desired = userIds == null ? List.of() : userIds.stream().distinct().toList();

        List<User> desiredUsers = new ArrayList<>();
        for (Long id : desired) {
            User user = getUser(id);
            if (user.getRole() != Role.PARISH_ADMIN) {
                throw new BadRequestException("User " + id + " is not a PARISH_ADMIN");
            }
            desiredUsers.add(user);
        }

        // Unassign current admins that are no longer desired.
        for (User current : userRepository.findByParishIdAndRole(parishId, Role.PARISH_ADMIN)) {
            if (!desired.contains(current.getId())) {
                current.setParishId(null);
            }
        }
        // Assign (or move) the desired admins to this parish.
        for (User user : desiredUsers) {
            user.setParishId(parishId);
        }

        return desiredUsers.stream().map(UserResponse::from).toList();
    }
}
