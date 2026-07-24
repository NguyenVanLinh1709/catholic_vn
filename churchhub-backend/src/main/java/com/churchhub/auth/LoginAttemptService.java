package com.churchhub.auth;

import org.springframework.security.authentication.LockedException;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory login throttling, keyed by email. Single-instance only: if this
 * app is ever scaled to multiple instances, move this to a shared store
 * (e.g. Redis) so attempts are counted across all of them.
 */
@Component
public class LoginAttemptService {

    private static final int MAX_ATTEMPTS = 5;
    private static final Duration LOCK_DURATION = Duration.ofMinutes(15);

    private record Attempt(int failures, Instant lockedUntil) {
    }

    private final ConcurrentHashMap<String, Attempt> attempts = new ConcurrentHashMap<>();

    public void checkNotLocked(String email) {
        String key = normalize(email);
        Attempt attempt = attempts.get(key);
        if (attempt == null || attempt.lockedUntil() == null) {
            return;
        }
        if (Instant.now().isBefore(attempt.lockedUntil())) {
            throw new LockedException("Too many failed login attempts. Please try again in a few minutes.");
        }
        attempts.remove(key);
    }

    public void onFailure(String email) {
        attempts.compute(normalize(email), (k, existing) -> {
            int failures = (existing == null ? 0 : existing.failures()) + 1;
            Instant lockedUntil = failures >= MAX_ATTEMPTS ? Instant.now().plus(LOCK_DURATION) : null;
            return new Attempt(failures, lockedUntil);
        });
    }

    public void onSuccess(String email) {
        attempts.remove(normalize(email));
    }

    private String normalize(String email) {
        return email.toLowerCase(Locale.ROOT);
    }
}
