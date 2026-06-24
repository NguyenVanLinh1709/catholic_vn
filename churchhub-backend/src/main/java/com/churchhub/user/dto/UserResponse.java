package com.churchhub.user.dto;

import com.churchhub.user.Role;
import com.churchhub.user.User;

import java.time.OffsetDateTime;

public record UserResponse(
        Long id,
        String email,
        String fullName,
        Role role,
        Long parishId,
        boolean enabled,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
    public static UserResponse from(User u) {
        return new UserResponse(
                u.getId(),
                u.getEmail(),
                u.getFullName(),
                u.getRole(),
                u.getParishId(),
                u.isEnabled(),
                u.getCreatedAt(),
                u.getUpdatedAt());
    }
}
