package com.churchhub.massschedule.dto;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/** SUNDAY only ever means ISO day-of-week 7; WEEKDAY never means Sunday (day 7). */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = ConsistentDayOfWeekValidator.class)
public @interface ConsistentDayOfWeek {

    String message() default "dayOfWeek is inconsistent with dayType";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
