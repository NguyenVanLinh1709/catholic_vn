package com.churchhub.massschedule;

import com.churchhub.massschedule.dto.MassScheduleRequest;
import com.churchhub.massschedule.dto.MassScheduleResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class MassScheduleController {

    private final MassScheduleService massScheduleService;

    @GetMapping("/api/parishes/{parishId}/mass-schedules")
    public List<MassScheduleResponse> listByParish(@PathVariable Long parishId) {
        return massScheduleService.listByParish(parishId);
    }

    @PostMapping("/api/parishes/{parishId}/mass-schedules")
    @ResponseStatus(HttpStatus.CREATED)
    public MassScheduleResponse create(@PathVariable Long parishId,
                                       @Valid @RequestBody MassScheduleRequest request) {
        return massScheduleService.create(parishId, request);
    }

    @PutMapping("/api/mass-schedules/{id}")
    public MassScheduleResponse update(@PathVariable Long id,
                                       @Valid @RequestBody MassScheduleRequest request) {
        return massScheduleService.update(id, request);
    }

    @DeleteMapping("/api/mass-schedules/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        massScheduleService.delete(id);
    }
}
