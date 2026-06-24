package com.churchhub.article.dto;

import com.churchhub.article.ArticleStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ArticleRequest(
        @NotBlank @Size(max = 255) String title,
        @Size(max = 255) String slug,
        String content,
        @Size(max = 500) String coverUrl,
        ArticleStatus status
) {
}
