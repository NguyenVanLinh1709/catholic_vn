package com.churchhub.user.dto;

import com.churchhub.user.Role;
import jakarta.validation.constraints.Size;

public record UpdateUserRequest(
        @Size(max = 255) String fullName,
        Role role,
        Long parishId,
        Boolean enabled,
        @Size(min = 8, max = 100) String password
) {
}
