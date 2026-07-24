package com.churchhub.registration;

import com.churchhub.common.TooManyRequestsException;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RegistrationRateLimiterTest {

    private final RegistrationRateLimiter limiter = new RegistrationRateLimiter();

    @Test
    void allowsUpToFiveSubmissionsFromTheSameIp() {
        String ip = "10.0.0.1";
        assertThatCode(() -> {
            for (int i = 0; i < 5; i++) {
                limiter.checkAllowed(ip);
            }
        }).doesNotThrowAnyException();
    }

    @Test
    void blocksTheSixthSubmissionFromTheSameIp() {
        String ip = "10.0.0.2";
        for (int i = 0; i < 5; i++) {
            limiter.checkAllowed(ip);
        }
        assertThatThrownBy(() -> limiter.checkAllowed(ip)).isInstanceOf(TooManyRequestsException.class);
    }

    @Test
    void tracksDifferentIpsIndependently() {
        for (int i = 0; i < 5; i++) {
            limiter.checkAllowed("10.0.0.3");
        }
        assertThatCode(() -> limiter.checkAllowed("10.0.0.4")).doesNotThrowAnyException();
    }
}
