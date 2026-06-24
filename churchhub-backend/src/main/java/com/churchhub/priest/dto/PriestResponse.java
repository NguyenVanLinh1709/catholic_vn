package com.churchhub.priest.dto;

import com.churchhub.priest.Priest;
import com.churchhub.priest.PriestRole;

public record PriestResponse(
        Long id,
        Long parishId,
        String fullName,
        PriestRole role,
        String phone,
        String photoUrl,
        int orderIndex
) {
    public static PriestResponse from(Priest p) {
        return new PriestResponse(
                p.getId(),
                p.getParishId(),
                p.getFullName(),
                p.getRole(),
                p.getPhone(),
                p.getPhotoUrl(),
                p.getOrderIndex());
    }
}
