package com.churchhub.massschedule.dto;

import com.churchhub.massschedule.DayType;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class ConsistentDayOfWeekValidator implements ConstraintValidator<ConsistentDayOfWeek, MassScheduleRequest> {

    @Override
    public boolean isValid(MassScheduleRequest request, ConstraintValidatorContext context) {
        if (request == null || request.dayType() == null || request.dayOfWeek() == null) {
            return true;
        }
        return switch (request.dayType()) {
            case SUNDAY -> request.dayOfWeek() == 7;
            case WEEKDAY -> request.dayOfWeek() != 7;
            case SPECIAL -> true;
        };
    }
}
