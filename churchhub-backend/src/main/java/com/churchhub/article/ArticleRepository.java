package com.churchhub.article;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ArticleRepository extends JpaRepository<Article, Long> {

    Page<Article> findByParishIdAndStatus(Long parishId, ArticleStatus status, Pageable pageable);

    boolean existsByParishIdAndSlug(Long parishId, String slug);
}
