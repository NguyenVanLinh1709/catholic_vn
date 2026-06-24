package com.churchhub.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {

    public static final String TOKEN_TYPE_CLAIM = "type";
    public static final String ACCESS_TOKEN = "access";
    public static final String REFRESH_TOKEN = "refresh";

    private static final String ROLE_CLAIM = "role";
    private static final String PARISH_CLAIM = "parishId";

    private final SecretKey signingKey;
    private final long accessExpirationMs;
    private final long refreshExpirationMs;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-expiration}") long accessExpirationMs,
            @Value("${app.jwt.refresh-expiration}") long refreshExpirationMs) {
        this.signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessExpirationMs = accessExpirationMs;
        this.refreshExpirationMs = refreshExpirationMs;
    }

    public String generateAccessToken(AuthUser user) {
        return buildToken(user, ACCESS_TOKEN, accessExpirationMs,
                Map.of(ROLE_CLAIM, user.getRole().name(),
                        PARISH_CLAIM, String.valueOf(user.getParishId())));
    }

    public String generateRefreshToken(AuthUser user) {
        return buildToken(user, REFRESH_TOKEN, refreshExpirationMs, Map.of());
    }

    public long getAccessExpirationMs() {
        return accessExpirationMs;
    }

    public String extractSubject(String token) {
        return parse(token).getSubject();
    }

    public String extractTokenType(String token) {
        return parse(token).get(TOKEN_TYPE_CLAIM, String.class);
    }

    public boolean isAccessToken(String token) {
        return ACCESS_TOKEN.equals(extractTokenType(token));
    }

    public boolean isRefreshToken(String token) {
        return REFRESH_TOKEN.equals(extractTokenType(token));
    }

    /** Parses and validates signature + expiry; throws JwtException if invalid. */
    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private String buildToken(AuthUser user, String type, long ttlMs, Map<String, Object> extraClaims) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + ttlMs);
        return Jwts.builder()
                .subject(user.getEmail())
                .claim(TOKEN_TYPE_CLAIM, type)
                .claims(extraClaims)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(signingKey)
                .compact();
    }
}
