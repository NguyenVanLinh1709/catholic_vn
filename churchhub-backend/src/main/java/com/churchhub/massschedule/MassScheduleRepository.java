package com.churchhub.massschedule;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MassScheduleRepository extends JpaRepository<MassSchedule, Long> {

    List<MassSchedule> findByParishIdOrderByDayTypeAscDayOfWeekAscMassTimeAsc(Long parishId);
}
