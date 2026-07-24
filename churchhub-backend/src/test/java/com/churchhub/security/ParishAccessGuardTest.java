package com.churchhub.security;

import com.churchhub.common.ForbiddenException;
import com.churchhub.user.Role;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ParishAccessGuardTest {

    private final ParishAccessGuard guard = new ParishAccessGuard();

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void superAdminCanManageAnyParish() {
        AuthUser superAdmin = authUser(Role.SUPER_ADMIN, null);
        assertThat(guard.canManage(1L, superAdmin)).isTrue();
        assertThat(guard.canManage(999L, superAdmin)).isTrue();
    }

    @Test
    void parishAdminCanOnlyManageOwnParish() {
        AuthUser parishAdmin = authUser(Role.PARISH_ADMIN, 5L);
        assertThat(guard.canManage(5L, parishAdmin)).isTrue();
        assertThat(guard.canManage(6L, parishAdmin)).isFalse();
    }

    @Test
    void unassignedParishAdminCanManageNothing() {
        AuthUser unassigned = authUser(Role.PARISH_ADMIN, null);
        assertThat(guard.canManage(5L, unassigned)).isFalse();
    }

    @Test
    void nullPrincipalOrParishIdIsDenied() {
        AuthUser superAdmin = authUser(Role.SUPER_ADMIN, null);
        assertThat(guard.canManage(null, superAdmin)).isFalse();
        assertThat(guard.canManage(5L, null)).isFalse();
    }

    @Test
    void assertCanManageThrowsForbiddenWhenDenied() {
        setCurrentUser(authUser(Role.PARISH_ADMIN, 5L));
        assertThatThrownBy(() -> guard.assertCanManage(6L)).isInstanceOf(ForbiddenException.class);
    }

    @Test
    void assertCanManagePassesWhenAllowed() {
        setCurrentUser(authUser(Role.PARISH_ADMIN, 5L));
        assertThatCode(() -> guard.assertCanManage(5L)).doesNotThrowAnyException();
    }

    @Test
    void assertCanManageThrowsForbiddenWhenUnauthenticated() {
        SecurityContextHolder.clearContext();
        assertThatThrownBy(() -> guard.assertCanManage(5L)).isInstanceOf(ForbiddenException.class);
    }

    private AuthUser authUser(Role role, Long parishId) {
        return new AuthUser(1L, "user@test.com", "hash", role, parishId, true, 0);
    }

    private void setCurrentUser(AuthUser user) {
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities()));
    }
}
