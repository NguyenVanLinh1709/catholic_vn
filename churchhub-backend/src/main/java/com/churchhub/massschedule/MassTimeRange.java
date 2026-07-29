package com.churchhub.massschedule;

import java.time.LocalTime;

/** Coarse part-of-day bucket used to filter mass schedules by time (public directory filter). */
public enum MassTimeRange {
    MORNING(LocalTime.MIN, LocalTime.NOON),
    AFTERNOON(LocalTime.NOON, LocalTime.of(18, 0)),
    EVENING(LocalTime.of(18, 0), null);

    private final LocalTime start;
    private final LocalTime end;

    MassTimeRange(LocalTime start, LocalTime end) {
        this.start = start;
        this.end = end;
    }

    /** Inclusive lower bound. */
    public LocalTime start() {
        return start;
    }

    /** Exclusive upper bound; null means "end of day". */
    public LocalTime end() {
        return end;
    }
}
