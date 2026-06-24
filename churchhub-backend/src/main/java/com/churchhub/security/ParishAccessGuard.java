package com.churchhub.security;

import com.churchhub.common.ForbiddenException;
import org.springframework.stereotype.Component;

/**
 * Reusable, parish-ownership authorization.
 *
 * <p>Usable two ways:
 * <ul>
 *   <li>From SpEL on a controller/service method:
 *       {@code @PreAuthorize("@parishAccess.canManage(#parishId, principal)")}</li>
 *   <li>From the service layer: {@link #assertCanManage(Long)} which reads the
 *       current principal from the security context and throws 403 on denial.</li>
 * </ul>
 *
 * Rule: SUPER_ADMIN passes for every parish; PARISH_ADMIN passes only when the
 * resource's parishId equals their own; anyone else is denied.
 */
@Component("parishAccess")
public class ParishAccessGuard {

    /** SpEL-friendly boolean check (no exceptions). */
    public boolean canManage(Long parishId, AuthUser principal) {
        if (principal == null || parishId == null) {
            return false;
        }
        if (principal.isSuperAdmin()) {
            return true;
        }
        return parishId.equals(principal.getParishId());
    }

    /** Service-layer guard: resolves the principal and throws 403 on denial. */
    public void assertCanManage(Long parishId) {
        AuthUser principal = SecurityUtils.requireCurrentUser();
        if (!canManage(parishId, principal)) {
            throw new ForbiddenException("You are not allowed to manage parish " + parishId);
        }
    }
}
