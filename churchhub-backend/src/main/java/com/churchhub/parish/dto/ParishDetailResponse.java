package com.churchhub.parish.dto;

import com.churchhub.massschedule.dto.MassScheduleResponse;
import com.churchhub.parish.Parish;
import com.churchhub.priest.dto.PriestResponse;

import java.util.List;

/** Detail view returned by GET /api/parishes/{slug}: parish + priests + mass schedules. */
public record ParishDetailResponse(
        ParishResponse parish,
        List<PriestResponse> priests,
        List<MassScheduleResponse> massSchedules
) {
    public static ParishDetailResponse of(Parish parish,
                                          List<PriestResponse> priests,
                                          List<MassScheduleResponse> massSchedules) {
        return new ParishDetailResponse(ParishResponse.from(parish), priests, massSchedules);
    }
}
