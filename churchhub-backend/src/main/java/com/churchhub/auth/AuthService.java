package com.churchhub.auth;

import com.churchhub.auth.dto.LoginRequest;
import com.churchhub.auth.dto.RefreshRequest;
import com.churchhub.auth.dto.TokenResponse;
import com.churchhub.security.AuthUser;
import com.churchhub.security.JwtService;
import com.churchhub.user.User;
import com.churchhub.user.UserRepository;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid credentials");
        }
        if (!user.isEnabled()) {
            throw new DisabledException("Account is disabled");
        }

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
            return issueTokens(AuthUser.from(user));
        } catch (JwtException | IllegalArgumentException ex) {
            throw new BadCredentialsException("Invalid or expired refresh token");
        }
    }

    private TokenResponse issueTokens(AuthUser principal) {
        String access = jwtService.generateAccessToken(principal);
        String refresh = jwtService.generateRefreshToken(principal);
        return TokenResponse.of(access, refresh, jwtService.getAccessExpirationMs());
    }
}
