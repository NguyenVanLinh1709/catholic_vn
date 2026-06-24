package com.churchhub.parish.dto;

import com.churchhub.parish.Parish;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record ParishResponse(
        Long id,
        String name,
        String slug,
        String address,
        String phone,
        BigDecimal latitude,
        BigDecimal longitude,
        String description,
        boolean active,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
    public static ParishResponse from(Parish p) {
        return new ParishResponse(
                p.getId(),
                p.getName(),
                p.getSlug(),
                p.getAddress(),
                p.getPhone(),
                p.getLatitude(),
                p.getLongitude(),
                p.getDescription(),
                p.isActive(),
                p.getCreatedAt(),
                p.getUpdatedAt());
    }
}
