package com.churchhub.priest.dto;

import com.churchhub.priest.PriestRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record PriestRequest(
        @NotBlank @Size(max = 255) String fullName,
        @NotNull PriestRole role,
        @Size(max = 30) String phone,
        @Size(max = 500) String photoUrl,
        Integer orderIndex
) {
}
