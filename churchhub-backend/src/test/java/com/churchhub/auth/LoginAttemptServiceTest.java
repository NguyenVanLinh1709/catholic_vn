package com.churchhub.auth;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.LockedException;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class LoginAttemptServiceTest {

    private final LoginAttemptService service = new LoginAttemptService();

    @Test
    void allowsLoginWhenNoPriorFailures() {
        assertThatCode(() -> service.checkNotLocked("fresh@test.com")).doesNotThrowAnyException();
    }

    @Test
    void locksAfterFiveFailures() {
        String email = "locked@test.com";
        for (int i = 0; i < 5; i++) {
            service.onFailure(email);
        }
        assertThatThrownBy(() -> service.checkNotLocked(email)).isInstanceOf(LockedException.class);
    }

    @Test
    void fourFailuresDoNotLock() {
        String email = "almost-locked@test.com";
        for (int i = 0; i < 4; i++) {
            service.onFailure(email);
        }
        assertThatCode(() -> service.checkNotLocked(email)).doesNotThrowAnyException();
    }

    @Test
    void successResetsTheFailureCount() {
        String email = "reset@test.com";
        for (int i = 0; i < 4; i++) {
            service.onFailure(email);
        }
        service.onSuccess(email);
        service.onFailure(email);

        assertThatCode(() -> service.checkNotLocked(email)).doesNotThrowAnyException();
    }

    @Test
    void lockoutKeyIsCaseInsensitive() {
        String email = "Case@Test.com";
        for (int i = 0; i < 5; i++) {
            service.onFailure(email);
        }
        assertThatThrownBy(() -> service.checkNotLocked("case@test.com")).isInstanceOf(LockedException.class);
    }
}
