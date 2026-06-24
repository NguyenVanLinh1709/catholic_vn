package com.churchhub.article.dto;

import com.churchhub.article.Article;
import com.churchhub.article.ArticleStatus;

import java.time.OffsetDateTime;

public record ArticleResponse(
        Long id,
        Long parishId,
        Long authorId,
        String title,
        String slug,
        String content,
        String coverUrl,
        ArticleStatus status,
        OffsetDateTime publishedAt,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {
    public static ArticleResponse from(Article a) {
        return new ArticleResponse(
                a.getId(),
                a.getParishId(),
                a.getAuthorId(),
                a.getTitle(),
                a.getSlug(),
                a.getContent(),
                a.getCoverUrl(),
                a.getStatus(),
                a.getPublishedAt(),
                a.getCreatedAt(),
                a.getUpdatedAt());
    }
}
