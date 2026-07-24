package com.churchhub.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service
public class JwtService {

    public static final String TOKEN_TYPE_CLAIM = "type";
    public static final String ACCESS_TOKEN = "access";
    public static final String REFRESH_TOKEN = "refresh";

    private static final String ROLE_CLAIM = "role";
    private static final String PARISH_CLAIM = "parishId";
    private static final String TOKEN_VERSION_CLAIM = "tv";
    private static final int MIN_SECRET_BYTES = 32;

    private final SecretKey signingKey;
    private final long accessExpirationMs;
    private final long refreshExpirationMs;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-expiration}") long accessExpirationMs,
            @Value("${app.jwt.refresh-expiration}") long refreshExpirationMs) {
        byte[] secretBytes = secret.getBytes(StandardCharsets.UTF_8);
        if (secretBytes.length < MIN_SECRET_BYTES) {
            throw new IllegalStateException(
                    "app.jwt.secret (JWT_SECRET) must be at least " + MIN_SECRET_BYTES
                            + " bytes; refusing to start with a weak signing key.");
        }
        this.signingKey = Keys.hmacShaKeyFor(secretBytes);
        this.accessExpirationMs = accessExpirationMs;
        this.refreshExpirationMs = refreshExpirationMs;
    }

    public String generateAccessToken(AuthUser user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(ROLE_CLAIM, user.getRole().name());
        // Omit entirely for SUPER_ADMIN rather than stringifying null as the literal "null".
        if (user.getParishId() != null) {
            claims.put(PARISH_CLAIM, user.getParishId());
        }
        claims.put(TOKEN_VERSION_CLAIM, user.getTokenVersion());
        return buildToken(user, ACCESS_TOKEN, accessExpirationMs, claims);
    }

    public String generateRefreshToken(AuthUser user) {
        return buildToken(user, REFRESH_TOKEN, refreshExpirationMs,
                Map.of(TOKEN_VERSION_CLAIM, user.getTokenVersion()));
    }

    /** Missing claim (tokens issued before this field existed) is treated as version 0. */
    public int extractTokenVersion(String token) {
        Integer version = parse(token).get(TOKEN_VERSION_CLAIM, Integer.class);
        return version == null ? 0 : version;
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
