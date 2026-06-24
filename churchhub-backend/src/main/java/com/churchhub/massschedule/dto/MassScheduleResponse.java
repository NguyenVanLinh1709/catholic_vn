package com.churchhub.massschedule.dto;

import com.churchhub.massschedule.DayType;
import com.churchhub.massschedule.MassSchedule;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalTime;

public record MassScheduleResponse(
        Long id,
        Long parishId,
        DayType dayType,
        Short dayOfWeek,
        @JsonFormat(pattern = "HH:mm") LocalTime massTime,
        String label,
        String note
) {
    public static MassScheduleResponse from(MassSchedule m) {
        return new MassScheduleResponse(
                m.getId(),
                m.getParishId(),
                m.getDayType(),
                m.getDayOfWeek(),
                m.getMassTime(),
                m.getLabel(),
                m.getNote());
    }
}
