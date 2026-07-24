package com.churchhub.registration.dto;

import jakarta.validation.constraints.Size;

public record RejectRegistrationRequest(
        @Size(max = 500) String reason
) {
}
