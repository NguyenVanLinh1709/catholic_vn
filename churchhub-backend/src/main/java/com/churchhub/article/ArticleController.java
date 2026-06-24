package com.churchhub.article;

import com.churchhub.article.dto.ArticleRequest;
import com.churchhub.article.dto.ArticleResponse;
import com.churchhub.article.dto.ArticleSummaryResponse;
import com.churchhub.common.PageResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleService articleService;

    @GetMapping("/api/parishes/{parishId}/articles")
    public PageResponse<ArticleSummaryResponse> listByParish(
            @PathVariable Long parishId,
            @PageableDefault(size = 10) Pageable pageable) {
        return articleService.listPublishedByParish(parishId, pageable);
    }

    @GetMapping("/api/articles/{id}")
    public ArticleResponse get(@PathVariable Long id) {
        return articleService.getReadable(id);
    }

    @PostMapping("/api/parishes/{parishId}/articles")
    @ResponseStatus(HttpStatus.CREATED)
    public ArticleResponse create(@PathVariable Long parishId, @Valid @RequestBody ArticleRequest request) {
        return articleService.create(parishId, request);
    }

    @PutMapping("/api/articles/{id}")
    public ArticleResponse update(@PathVariable Long id, @Valid @RequestBody ArticleRequest request) {
        return articleService.update(id, request);
    }

    @DeleteMapping("/api/articles/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        articleService.delete(id);
    }
}
