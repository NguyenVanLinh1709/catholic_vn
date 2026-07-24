package com.churchhub.security;

import com.churchhub.user.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {

    private static final String SECRET = "unit-test-jwt-signing-secret-key-1234567890";

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(SECRET, 900_000L, 604_800_000L);
    }

    @Test
    void rejectsSecretShorterThan32Bytes() {
        assertThatThrownBy(() -> new JwtService("too-short", 1000L, 1000L))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void accessTokenRoundTripsSubjectAndTypeAndVersion() {
        AuthUser user = authUser(Role.PARISH_ADMIN, 7L, 3);
        String token = jwtService.generateAccessToken(user);

        assertThat(jwtService.isAccessToken(token)).isTrue();
        assertThat(jwtService.isRefreshToken(token)).isFalse();
        assertThat(jwtService.extractSubject(token)).isEqualTo(user.getEmail());
        assertThat(jwtService.extractTokenVersion(token)).isEqualTo(3);
    }

    @Test
    void refreshTokenIsNeverAcceptedAsAccessToken() {
        AuthUser user = authUser(Role.SUPER_ADMIN, null, 0);
        String refresh = jwtService.generateRefreshToken(user);

        assertThat(jwtService.isRefreshToken(refresh)).isTrue();
        assertThat(jwtService.isAccessToken(refresh)).isFalse();
    }

    @Test
    void tokenVersionMismatchIsDetectable() {
        AuthUser user = authUser(Role.PARISH_ADMIN, 7L, 1);
        String token = jwtService.generateAccessToken(user);

        assertThat(jwtService.extractTokenVersion(token)).isNotEqualTo(2);
    }

    private AuthUser authUser(Role role, Long parishId, int tokenVersion) {
        return new AuthUser(1L, "jwt-test@test.com", "hash", role, parishId, true, tokenVersion);
    }
}
