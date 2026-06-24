package com.churchhub.massschedule;

import com.churchhub.common.NotFoundException;
import com.churchhub.massschedule.dto.MassScheduleRequest;
import com.churchhub.massschedule.dto.MassScheduleResponse;
import com.churchhub.parish.ParishRepository;
import com.churchhub.security.ParishAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MassScheduleService {

    private final MassScheduleRepository massScheduleRepository;
    private final ParishRepository parishRepository;
    private final ParishAccessGuard parishAccess;

    @Transactional(readOnly = true)
    public List<MassScheduleResponse> listByParish(Long parishId) {
        requireParish(parishId);
        return massScheduleRepository
                .findByParishIdOrderByDayTypeAscDayOfWeekAscMassTimeAsc(parishId).stream()
                .map(MassScheduleResponse::from)
                .toList();
    }

    @Transactional
    public MassScheduleResponse create(Long parishId, MassScheduleRequest request) {
        requireParish(parishId);
        parishAccess.assertCanManage(parishId);

        MassSchedule schedule = MassSchedule.builder()
                .parishId(parishId)
                .dayType(request.dayType())
                .dayOfWeek(request.dayOfWeek())
                .massTime(request.massTime())
                .label(request.label())
                .note(request.note())
                .build();
        return MassScheduleResponse.from(massScheduleRepository.save(schedule));
    }

    @Transactional
    public MassScheduleResponse update(Long id, MassScheduleRequest request) {
        MassSchedule schedule = getSchedule(id);
        parishAccess.assertCanManage(schedule.getParishId());

        schedule.setDayType(request.dayType());
        schedule.setDayOfWeek(request.dayOfWeek());
        schedule.setMassTime(request.massTime());
        schedule.setLabel(request.label());
        schedule.setNote(request.note());
        return MassScheduleResponse.from(massScheduleRepository.save(schedule));
    }

    @Transactional
    public void delete(Long id) {
        MassSchedule schedule = getSchedule(id);
        parishAccess.assertCanManage(schedule.getParishId());
        massScheduleRepository.delete(schedule);
    }

    private MassSchedule getSchedule(Long id) {
        return massScheduleRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("MassSchedule", id));
    }

    private void requireParish(Long parishId) {
        if (!parishRepository.existsById(parishId)) {
            throw NotFoundException.of("Parish", parishId);
        }
    }
}
