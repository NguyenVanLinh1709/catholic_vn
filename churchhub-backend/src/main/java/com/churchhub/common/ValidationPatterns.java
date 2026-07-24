package com.churchhub.common;

/** Shared jakarta.validation regex/message pairs so DTOs don't each hand-roll their own. */
public final class ValidationPatterns {

    /** Vietnamese phone: 10 digits starting with 0. Blank is allowed (pair with @Pattern only, no @NotBlank). */
    public static final String VN_PHONE_REGEX = "^(0\\d{9})?$";
    public static final String VN_PHONE_MESSAGE = "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0";

    private ValidationPatterns() {
    }
}
