package com.churchhub.registration.dto;

import com.churchhub.registration.AdminRegistration;
import com.churchhub.registration.RegistrationStatus;

import java.time.OffsetDateTime;

/** Never carries the password hash — only status/audit fields an admin needs to review a request. */
public record AdminRegistrationResponse(
        Long id,
        String email,
        String fullName,
        RegistrationStatus status,
        String rejectReason,
        Long reviewedBy,
        OffsetDateTime reviewedAt,
        Long createdUserId,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
    public static AdminRegistrationResponse from(AdminRegistration r) {
        return new AdminRegistrationResponse(
                r.getId(),
                r.getEmail(),
                r.getFullName(),
                r.getStatus(),
                r.getRejectReason(),
                r.getReviewedBy(),
                r.getReviewedAt(),
                r.getCreatedUserId(),
                r.getCreatedAt(),
                r.getUpdatedAt());
    }
}
