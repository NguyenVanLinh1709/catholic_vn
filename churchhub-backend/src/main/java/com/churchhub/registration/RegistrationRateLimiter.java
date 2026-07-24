package com.churchhub.registration;

import com.churchhub.common.TooManyRequestsException;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Throttles self-service registration submissions per client IP so the public
 * POST /api/registrations endpoint can't be used to spam the pending queue or
 * enumerate which emails already have accounts (keying by email wouldn't stop
 * an attacker who varies the target email on every call).
 *
 * In-memory, single-instance only (see LoginAttemptService for the same caveat).
 * Uses the request's remote address as-is; behind a reverse proxy without
 * forwarded-for trust configuration this degrades to one shared bucket.
 */
@Component
public class RegistrationRateLimiter {

    private static final int MAX_PER_WINDOW = 5;
    private static final Duration WINDOW = Duration.ofHours(1);

    private record Window(int count, Instant resetAt) {
    }

    private final ConcurrentHashMap<String, Window> windows = new ConcurrentHashMap<>();

    public void checkAllowed(String clientKey) {
        Instant now = Instant.now();
        Window updated = windows.compute(clientKey, (key, existing) -> {
            if (existing == null || now.isAfter(existing.resetAt())) {
                return new Window(1, now.plus(WINDOW));
            }
            return new Window(existing.count() + 1, existing.resetAt());
        });
        if (updated.count() > MAX_PER_WINDOW) {
            throw new TooManyRequestsException("Too many registration attempts, please try again later.");
        }
    }
}
