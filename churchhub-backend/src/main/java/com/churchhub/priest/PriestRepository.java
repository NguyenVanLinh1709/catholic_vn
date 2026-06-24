package com.churchhub.priest;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PriestRepository extends JpaRepository<Priest, Long> {

    List<Priest> findByParishIdOrderByOrderIndexAscIdAsc(Long parishId);
}
