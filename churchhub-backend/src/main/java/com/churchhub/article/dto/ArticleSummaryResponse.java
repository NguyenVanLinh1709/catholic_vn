package com.churchhub.article.dto;

import com.churchhub.article.Article;
import com.churchhub.article.ArticleStatus;

import java.time.OffsetDateTime;

/** Lightweight projection for list/paged views (no full content body). */
public record ArticleSummaryResponse(
        Long id,
        Long parishId,
        String title,
        String slug,
        String coverUrl,
        ArticleStatus status,
        OffsetDateTime publishedAt
) {
    public static ArticleSummaryResponse from(Article a) {
        return new ArticleSummaryResponse(
                a.getId(),
                a.getParishId(),
                a.getTitle(),
                a.getSlug(),
                a.getCoverUrl(),
                a.getStatus(),
                a.getPublishedAt());
    }
}
