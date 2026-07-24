package com.churchhub.registration.dto;

import jakarta.validation.constraints.NotNull;

public record ApproveRegistrationRequest(
        @NotNull Long parishId
) {
}
