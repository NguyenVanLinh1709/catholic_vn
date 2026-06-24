package com.churchhub.common;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Lightweight, serialization-stable page wrapper (avoids exposing Spring's
 * PageImpl internals over the API).
 */
public record PageResponse<T>(
        List<T> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean last
) {
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.isLast());
    }
}
