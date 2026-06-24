package com.churchhub.parish.dto;

import java.util.List;

/** Desired set of PARISH_ADMIN user ids that manage a parish. Empty/null = no admins. */
public record SetParishAdminsRequest(
        List<Long> userIds
) {
}
