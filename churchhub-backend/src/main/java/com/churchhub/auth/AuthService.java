package com.churchhub.auth;

import com.churchhub.auth.dto.LoginRequest;
import com.churchhub.auth.dto.RefreshRequest;
import com.churchhub.auth.dto.TokenResponse;
import com.churchhub.common.NotFoundException;
import com.churchhub.security.AuthUser;
import com.churchhub.security.JwtService;
import com.churchhub.security.SecurityUtils;
import com.churchhub.user.User;
import com.churchhub.user.UserRepository;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final LoginAttemptService loginAttemptService;

    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest request) {
        loginAttemptService.checkNotLocked(request.email());

        Optional<User> found = userRepository.findByEmail(request.email());
        if (found.isEmpty() || !passwordEncoder.matches(request.password(), found.get().getPasswordHash())) {
            loginAttemptService.onFailure(request.email());
            throw new BadCredentialsException("Invalid credentials");
        }
        User user = found.get();
        if (!user.isEnabled()) {
            throw new DisabledException("Account is disabled");
        }
        loginAttemptService.onSuccess(request.email());

        AuthUser principal = AuthUser.from(user);
        return issueTokens(principal);
    }

    @Transactional(readOnly = true)
    public TokenResponse refresh(RefreshRequest request) {
        String token = request.refreshToken();
        try {
            if (!jwtService.isRefreshToken(token)) {
                throw new BadCredentialsException("Invalid refresh token");
            }
            String email = jwtService.extractSubject(token);
            User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new BadCredentialsException("Invalid refresh token"));
            if (!user.isEnabled()) {
                throw new DisabledException("Account is disabled");
            }
            if (jwtService.extractTokenVersion(token) != user.getTokenVersion()) {
                throw new BadCredentialsException("Invalid refresh token");
            }
            return issueTokens(AuthUser.from(user));
        } catch (JwtException | IllegalArgumentException ex) {
            throw new BadCredentialsException("Invalid or expired refresh token");
        }
    }

    /** Bumps the caller's token version, invalidating every access/refresh token issued so far. */
    @Transactional
    public void logout() {
        AuthUser principal = SecurityUtils.requireCurrentUser();
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> NotFoundException.of("User", principal.getId()));
        user.setTokenVersion(user.getTokenVersion() + 1);
        userRepository.save(user);
    }

    private TokenResponse issueTokens(AuthUser principal) {
        String access = jwtService.generateAccessToken(principal);
        String refresh = jwtService.generateRefreshToken(principal);
        return TokenResponse.of(access, refresh, jwtService.getAccessExpirationMs());
    }
}
