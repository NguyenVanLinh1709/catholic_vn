package com.churchhub.massschedule;

import com.churchhub.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalTime;

@Entity
@Table(name = "mass_schedules")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MassSchedule extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "parish_id", nullable = false)
    private Long parishId;

    @Enumerated(EnumType.STRING)
    @Column(name = "day_type", nullable = false, length = 20)
    private DayType dayType;

    /** 1=Mon .. 7=Sun (ISO). Null = applies to the whole day_type. */
    @Column(name = "day_of_week")
    private Short dayOfWeek;

    @Column(name = "mass_time", nullable = false)
    private LocalTime massTime;

    @Column(name = "label")
    private String label;

    @Column(name = "note", length = 500)
    private String note;
}
