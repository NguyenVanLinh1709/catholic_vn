package com.churchhub.massschedule.dto;

import com.churchhub.massschedule.DayType;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalTime;

public record MassScheduleRequest(
        @NotNull DayType dayType,
        @Min(1) @Max(7) Short dayOfWeek,
        @NotNull @JsonFormat(pattern = "HH:mm") LocalTime massTime,
        @Size(max = 255) String label,
        @Size(max = 500) String note
) {
}
