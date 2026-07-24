package com.churchhub.massschedule.dto;

import com.churchhub.massschedule.DayType;
import org.junit.jupiter.api.Test;

import java.time.LocalTime;

import static org.assertj.core.api.Assertions.assertThat;

class ConsistentDayOfWeekValidatorTest {

    private final ConsistentDayOfWeekValidator validator = new ConsistentDayOfWeekValidator();

    @Test
    void sundayWithDayOfWeekSevenIsValid() {
        assertThat(validator.isValid(request(DayType.SUNDAY, (short) 7), null)).isTrue();
    }

    @Test
    void sundayWithAnyOtherDayOfWeekIsInvalid() {
        assertThat(validator.isValid(request(DayType.SUNDAY, (short) 3), null)).isFalse();
    }

    @Test
    void sundayWithNullDayOfWeekIsValid() {
        assertThat(validator.isValid(request(DayType.SUNDAY, null), null)).isTrue();
    }

    @Test
    void weekdayWithDayOfWeekSevenIsInvalid() {
        assertThat(validator.isValid(request(DayType.WEEKDAY, (short) 7), null)).isFalse();
    }

    @Test
    void weekdayWithOtherDayOfWeekIsValid() {
        assertThat(validator.isValid(request(DayType.WEEKDAY, (short) 2), null)).isTrue();
    }

    @Test
    void weekdayWithNullDayOfWeekIsValid() {
        assertThat(validator.isValid(request(DayType.WEEKDAY, null), null)).isTrue();
    }

    @Test
    void specialAllowsAnyDayOfWeekIncludingNull() {
        assertThat(validator.isValid(request(DayType.SPECIAL, (short) 1), null)).isTrue();
        assertThat(validator.isValid(request(DayType.SPECIAL, (short) 7), null)).isTrue();
        assertThat(validator.isValid(request(DayType.SPECIAL, null), null)).isTrue();
    }

    private MassScheduleRequest request(DayType dayType, Short dayOfWeek) {
        return new MassScheduleRequest(dayType, dayOfWeek, LocalTime.of(5, 0), null, null);
    }
}
