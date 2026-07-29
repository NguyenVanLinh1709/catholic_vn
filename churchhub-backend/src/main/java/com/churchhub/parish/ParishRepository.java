package com.churchhub.parish;

import com.churchhub.massschedule.DayType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalTime;
import java.util.Optional;

public interface ParishRepository extends JpaRepository<Parish, Long> {

    Optional<Parish> findBySlug(String slug);

    boolean existsBySlug(String slug);

    /**
     * Directory search: name (optional, case-insensitive substring), province (optional, exact
     * match) / ward (optional, case-insensitive substring) region filter, active-only toggle
     * (hidden from PARISH_ADMIN/public unless SUPER_ADMIN), and an optional mass-schedule filter
     * (dayType / dayOfWeek / [startTime,endTime] time-of-day range - all optional, ANDed).
     * A parish matches the mass filter if at least one of its schedules satisfies all of the
     * supplied criteria. A schedule with a NULL dayOfWeek applies to every day of its dayType
     * (see MassSchedule.dayOfWeek), so it also matches a specific dayOfWeek filter consistent
     * with that meaning: NULL+SUNDAY matches dayOfWeek=7, NULL+WEEKDAY matches dayOfWeek 1-6.
     * <p>
     * {@code hasMassFilter}/{@code hasDayOfWeek}/{@code hasStartTime}/{@code hasEndTime} are
     * plain booleans (always non-null) rather than "{@code :param IS NULL}" checks: Postgres
     * can't infer a bind parameter's type from a bare IS NULL with no other typed context, and
     * wrapping it in CAST doesn't reliably fix it either for a null Short/LocalTime - both fail
     * with "cannot cast type bytea to ...". Booleans sidestep the inference problem entirely;
     * the value parameters are then only ever used where they already have typed context (e.g.
     * compared directly against a mapped entity attribute), which Postgres resolves correctly.
     * name/province/ward don't need this treatment - like dayType, a bare String/enum
     * {@code :param IS NULL} check resolves fine.
     */
    @Query(value = """
            SELECT p FROM Parish p
            WHERE (:name IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', CAST(:name AS string), '%')))
              AND (:province IS NULL OR p.province = :province)
              AND (:ward IS NULL OR LOWER(p.ward) LIKE LOWER(CONCAT('%', CAST(:ward AS string), '%')))
              AND (:activeOnly = FALSE OR p.active = TRUE)
              AND (
                    :hasMassFilter = FALSE
                    OR EXISTS (
                        SELECT 1 FROM MassSchedule m
                        WHERE m.parishId = p.id
                          AND (:dayType IS NULL OR m.dayType = :dayType)
                          AND (
                                :hasDayOfWeek = FALSE
                                OR m.dayOfWeek = :dayOfWeek
                                OR (m.dayOfWeek IS NULL AND (
                                      (:dayOfWeek = 7 AND m.dayType = com.churchhub.massschedule.DayType.SUNDAY)
                                      OR (:dayOfWeek <> 7 AND m.dayType = com.churchhub.massschedule.DayType.WEEKDAY)
                                    ))
                              )
                          AND (:hasStartTime = FALSE OR m.massTime >= :startTime)
                          AND (:hasEndTime = FALSE OR m.massTime <= :endTime)
                    )
                  )
            """,
            countQuery = """
            SELECT COUNT(p) FROM Parish p
            WHERE (:name IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', CAST(:name AS string), '%')))
              AND (:province IS NULL OR p.province = :province)
              AND (:ward IS NULL OR LOWER(p.ward) LIKE LOWER(CONCAT('%', CAST(:ward AS string), '%')))
              AND (:activeOnly = FALSE OR p.active = TRUE)
              AND (
                    :hasMassFilter = FALSE
                    OR EXISTS (
                        SELECT 1 FROM MassSchedule m
                        WHERE m.parishId = p.id
                          AND (:dayType IS NULL OR m.dayType = :dayType)
                          AND (
                                :hasDayOfWeek = FALSE
                                OR m.dayOfWeek = :dayOfWeek
                                OR (m.dayOfWeek IS NULL AND (
                                      (:dayOfWeek = 7 AND m.dayType = com.churchhub.massschedule.DayType.SUNDAY)
                                      OR (:dayOfWeek <> 7 AND m.dayType = com.churchhub.massschedule.DayType.WEEKDAY)
                                    ))
                              )
                          AND (:hasStartTime = FALSE OR m.massTime >= :startTime)
                          AND (:hasEndTime = FALSE OR m.massTime <= :endTime)
                    )
                  )
            """)
    Page<Parish> search(
            @Param("name") String name,
            @Param("province") String province,
            @Param("ward") String ward,
            @Param("activeOnly") boolean activeOnly,
            @Param("hasMassFilter") boolean hasMassFilter,
            @Param("dayType") DayType dayType,
            @Param("hasDayOfWeek") boolean hasDayOfWeek,
            @Param("dayOfWeek") Short dayOfWeek,
            @Param("hasStartTime") boolean hasStartTime,
            @Param("startTime") LocalTime startTime,
            @Param("hasEndTime") boolean hasEndTime,
            @Param("endTime") LocalTime endTime,
            Pageable pageable);
}
