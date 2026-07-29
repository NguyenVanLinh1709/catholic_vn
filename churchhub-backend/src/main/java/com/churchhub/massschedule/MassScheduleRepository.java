package com.churchhub.massschedule;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MassScheduleRepository extends JpaRepository<MassSchedule, Long> {

    /**
     * Ordered for direct display: WEEKDAY, then SUNDAY, then SPECIAL (the alphabetical order of
     * the enum name is meaningless), each grouped by dayOfWeek (NULL = "applies to every day of
     * that group" sorts first) then by time of day.
     */
    @Query("""
            SELECT m FROM MassSchedule m
            WHERE m.parishId = :parishId
            ORDER BY CASE m.dayType
                        WHEN com.churchhub.massschedule.DayType.WEEKDAY THEN 0
                        WHEN com.churchhub.massschedule.DayType.SUNDAY THEN 1
                        WHEN com.churchhub.massschedule.DayType.SPECIAL THEN 2
                     END,
                     m.dayOfWeek NULLS FIRST,
                     m.massTime
            """)
    List<MassSchedule> findByParishIdOrdered(@Param("parishId") Long parishId);
}
