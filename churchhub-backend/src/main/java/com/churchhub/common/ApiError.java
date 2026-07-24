package com.churchhub.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.http.HttpStatus;

import java.time.OffsetDateTime;
import java.util.List;

/**
 * Consistent JSON error body returned by {@link GlobalExceptionHandler} and,
 * for failures that happen before the dispatcher, {@code RestAuthEntryPoint}.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiError(
        OffsetDateTime timestamp,
        int status,
        String error,
        String message,
        String path,
        List<FieldViolation> errors
) {
    public record FieldViolation(String field, String message) {
    }

    public static ApiError of(int status, String error, String message, String path) {
        return new ApiError(OffsetDateTime.now(), status, error, message, path, null);
    }

    public static ApiError of(int status, String error, String message, String path, List<FieldViolation> errors) {
        return new ApiError(OffsetDateTime.now(), status, error, message, path, errors);
    }

    /** Derives status/error from an {@link HttpStatus} instead of repeating .value()/.getReasonPhrase() at each call site. */
    public static ApiError of(HttpStatus status, String message, String path) {
        return of(status.value(), status.getReasonPhrase(), message, path);
    }
}
