package com.churchhub.article;

import com.churchhub.article.dto.ArticleRequest;
import com.churchhub.article.dto.ArticleResponse;
import com.churchhub.article.dto.ArticleSummaryResponse;
import com.churchhub.common.NotFoundException;
import com.churchhub.common.PageResponse;
import com.churchhub.common.SlugUtil;
import com.churchhub.parish.ParishRepository;
import com.churchhub.security.AuthUser;
import com.churchhub.security.ParishAccessGuard;
import com.churchhub.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ArticleService {

    private final ArticleRepository articleRepository;
    private final ParishRepository parishRepository;
    private final ParishAccessGuard parishAccess;

    /** Public listing: only PUBLISHED articles of a parish, paged. */
    @Transactional(readOnly = true)
    public PageResponse<ArticleSummaryResponse> listPublishedByParish(Long parishId, Pageable pageable) {
        requireParish(parishId);
        return PageResponse.from(
                articleRepository.findByParishIdAndStatus(parishId, ArticleStatus.PUBLISHED, pageable)
                        .map(ArticleSummaryResponse::from));
    }

    /** Admin listing: every article (incl. DRAFT) of a parish, for its managers only. */
    @Transactional(readOnly = true)
    public PageResponse<ArticleSummaryResponse> listAllByParishForManage(Long parishId, Pageable pageable) {
        requireParish(parishId);
        parishAccess.assertCanManage(parishId);
        return PageResponse.from(
                articleRepository.findByParishId(parishId, pageable)
                        .map(ArticleSummaryResponse::from));
    }

    /** Public read: PUBLISHED is visible to all; DRAFT only to managers. */
    @Transactional(readOnly = true)
    public ArticleResponse getReadable(Long id) {
        Article article = getArticle(id);
        if (article.getStatus() != ArticleStatus.PUBLISHED && !canManage(article.getParishId())) {
            // Hide existence of unpublished articles from the public.
            throw NotFoundException.of("Article", id);
        }
        return ArticleResponse.from(article);
    }

    @Transactional
    public ArticleResponse create(Long parishId, ArticleRequest request) {
        requireParish(parishId);
        parishAccess.assertCanManage(parishId);

        ArticleStatus status = request.status() == null ? ArticleStatus.DRAFT : request.status();
        String slug = resolveSlug(parishId, request.slug(), request.title(), null);

        Article article = Article.builder()
                .parishId(parishId)
                .authorId(SecurityUtils.requireCurrentUser().getId())
                .title(request.title())
                .slug(slug)
                .content(request.content())
                .coverUrl(request.coverUrl())
                .status(status)
                .publishedAt(status == ArticleStatus.PUBLISHED ? OffsetDateTime.now() : null)
                .build();
        return ArticleResponse.from(articleRepository.save(article));
    }

    @Transactional
    public ArticleResponse update(Long id, ArticleRequest request) {
        Article article = getArticle(id);
        parishAccess.assertCanManage(article.getParishId());

        ArticleStatus newStatus = request.status() == null ? article.getStatus() : request.status();

        article.setTitle(request.title());
        article.setSlug(resolveSlug(article.getParishId(), request.slug(), request.title(), article));
        article.setContent(request.content());
        article.setCoverUrl(request.coverUrl());

        // First transition into PUBLISHED stamps published_at once.
        if (newStatus == ArticleStatus.PUBLISHED && article.getPublishedAt() == null) {
            article.setPublishedAt(OffsetDateTime.now());
        }
        article.setStatus(newStatus);

        return ArticleResponse.from(articleRepository.save(article));
    }

    @Transactional
    public void delete(Long id) {
        Article article = getArticle(id);
        parishAccess.assertCanManage(article.getParishId());
        articleRepository.delete(article);
    }

    private Article getArticle(Long id) {
        return articleRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Article", id));
    }

    private boolean canManage(Long parishId) {
        Optional<AuthUser> current = SecurityUtils.currentUser();
        return current.isPresent() && parishAccess.canManage(parishId, current.get());
    }

    private void requireParish(Long parishId) {
        if (!parishRepository.existsById(parishId)) {
            throw NotFoundException.of("Parish", parishId);
        }
    }

    /**
     * Resolves the slug: use the client value if provided, otherwise derive it
     * from the title. Guarantees uniqueness within the parish by suffixing.
     */
    private String resolveSlug(Long parishId, String requestedSlug, String title, Article current) {
        String base = (requestedSlug != null && !requestedSlug.isBlank())
                ? SlugUtil.slugify(requestedSlug)
                : SlugUtil.slugify(title);
        if (base.isBlank()) {
            base = "bai-viet";
        }
        // Unchanged slug on update -> keep as-is.
        if (current != null && base.equals(current.getSlug())) {
            return base;
        }
        String candidate = base;
        int suffix = 2;
        while (articleRepository.existsByParishIdAndSlug(parishId, candidate)) {
            candidate = base + "-" + suffix++;
        }
        return candidate;
    }
}
