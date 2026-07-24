package com.churchhub.priest.dto;

import com.churchhub.common.ValidationPatterns;
import com.churchhub.priest.PriestRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record PriestRequest(
        @NotBlank @Size(max = 255) String fullName,
        @NotNull PriestRole role,
        @Pattern(regexp = ValidationPatterns.VN_PHONE_REGEX, message = ValidationPatterns.VN_PHONE_MESSAGE)
        String phone,
        @Size(max = 500) String photoUrl,
        Integer orderIndex
) {
}
