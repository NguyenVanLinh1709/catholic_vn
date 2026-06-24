package com.churchhub.parish;

import com.churchhub.common.ConflictException;
import com.churchhub.common.NotFoundException;
import com.churchhub.common.PageResponse;
import com.churchhub.common.SlugUtil;
import com.churchhub.massschedule.MassSchedule;
import com.churchhub.massschedule.MassScheduleRepository;
import com.churchhub.massschedule.dto.MassScheduleRequest;
import com.churchhub.massschedule.dto.MassScheduleResponse;
import com.churchhub.parish.dto.ParishDetailResponse;
import com.churchhub.parish.dto.ParishRequest;
import com.churchhub.parish.dto.ParishResponse;
import com.churchhub.priest.PriestRepository;
import com.churchhub.priest.dto.PriestResponse;
import com.churchhub.security.ParishAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ParishService {

    private final ParishRepository parishRepository;
    private final PriestRepository priestRepository;
    private final MassScheduleRepository massScheduleRepository;
    private final ParishAccessGuard parishAccess;

    @Transactional(readOnly = true)
    public PageResponse<ParishResponse> search(String name, Pageable pageable) {
        Page<Parish> page = StringUtils.hasText(name)
                ? parishRepository.findByNameContainingIgnoreCase(name.trim(), pageable)
                : parishRepository.findAll(pageable);
        return PageResponse.from(page.map(ParishResponse::from));
    }

    @Transactional(readOnly = true)
    public ParishDetailResponse getBySlug(String slug) {
        Parish parish = parishRepository.findBySlug(slug)
                .orElseThrow(() -> NotFoundException.of("Parish", slug));

        List<PriestResponse> priests = priestRepository
                .findByParishIdOrderByOrderIndexAscIdAsc(parish.getId()).stream()
                .map(PriestResponse::from)
                .toList();
        List<MassScheduleResponse> schedules = massScheduleRepository
                .findByParishIdOrderByDayTypeAscDayOfWeekAscMassTimeAsc(parish.getId()).stream()
                .map(MassScheduleResponse::from)
                .toList();

        return ParishDetailResponse.of(parish, priests, schedules);
    }

    @Transactional
    public ParishDetailResponse create(ParishRequest request) {
        String slug = ensureUniqueSlug(resolveBaseSlug(request), null);

        Parish parish = Parish.builder()
                .name(request.name())
                .slug(slug)
                .address(request.address())
                .phone(request.phone())
                .latitude(request.latitude())
                .longitude(request.longitude())
                .description(request.description())
                .active(request.isActive() == null || request.isActive())
                .build();
        Parish saved = parishRepository.save(parish);

        List<MassScheduleResponse> schedules = saveSchedules(saved.getId(), request.massSchedules());
        return ParishDetailResponse.of(saved, List.of(), schedules);
    }

    /** Persist the mass schedules (giờ lễ) supplied alongside a newly created parish. */
    private List<MassScheduleResponse> saveSchedules(Long parishId, List<MassScheduleRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return List.of();
        }
        List<MassSchedule> schedules = requests.stream()
                .map(r -> MassSchedule.builder()
                        .parishId(parishId)
                        .dayType(r.dayType())
                        .dayOfWeek(r.dayOfWeek())
                        .massTime(r.massTime())
                        .label(r.label())
                        .note(r.note())
                        .build())
                .toList();
        return massScheduleRepository.saveAll(schedules).stream()
                .map(MassScheduleResponse::from)
                .toList();
    }

    @Transactional
    public ParishResponse update(Long id, ParishRequest request) {
        Parish parish = getParish(id);
        // SUPER_ADMIN passes; PARISH_ADMIN only for their own parish.
        parishAccess.assertCanManage(id);

        String base = resolveBaseSlug(request);
        if (!base.equals(parish.getSlug())) {
            parish.setSlug(ensureUniqueSlug(base, id));
        }
        parish.setName(request.name());
        parish.setAddress(request.address());
        parish.setPhone(request.phone());
        parish.setLatitude(request.latitude());
        parish.setLongitude(request.longitude());
        parish.setDescription(request.description());
        if (request.isActive() != null) {
            parish.setActive(request.isActive());
        }
        return ParishResponse.from(parishRepository.save(parish));
    }

    @Transactional
    public void delete(Long id) {
        Parish parish = getParish(id);
        parishRepository.delete(parish);
    }

    private Parish getParish(Long id) {
        return parishRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Parish", id));
    }

    /** Slug is always derived from the parish name; clients no longer supply it. */
    private String resolveBaseSlug(ParishRequest request) {
        String base = SlugUtil.slugify(request.name());
        if (base.isBlank()) {
            throw new ConflictException("Unable to derive a slug from the provided name");
        }
        return base;
    }

    /** Slug is globally unique. Suffix -2, -3, ... if needed. Ignores the row being updated. */
    private String ensureUniqueSlug(String base, Long currentId) {
        String candidate = base;
        int suffix = 2;
        while (slugTaken(candidate, currentId)) {
            candidate = base + "-" + suffix++;
        }
        return candidate;
    }

    private boolean slugTaken(String slug, Long currentId) {
        return parishRepository.findBySlug(slug)
                .filter(p -> !p.getId().equals(currentId))
                .isPresent();
    }
}
