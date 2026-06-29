package com.churchhub.priest.dto;

import com.churchhub.priest.PriestRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record PriestRequest(
        @NotBlank @Size(max = 255) String fullName,
        @NotNull PriestRole role,
        @Pattern(regexp = "^(0\\d{9})?$", message = "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0")
        String phone,
        @Size(max = 500) String photoUrl,
        Integer orderIndex
) {
}
