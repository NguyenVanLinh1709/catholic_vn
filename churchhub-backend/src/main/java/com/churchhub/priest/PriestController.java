package com.churchhub.priest;

import com.churchhub.priest.dto.PriestRequest;
import com.churchhub.priest.dto.PriestResponse;
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
public class PriestController {

    private final PriestService priestService;

    @GetMapping("/api/parishes/{parishId}/priests")
    public List<PriestResponse> listByParish(@PathVariable Long parishId) {
        return priestService.listByParish(parishId);
    }

    @PostMapping("/api/parishes/{parishId}/priests")
    @ResponseStatus(HttpStatus.CREATED)
    public PriestResponse create(@PathVariable Long parishId, @Valid @RequestBody PriestRequest request) {
        return priestService.create(parishId, request);
    }

    @PutMapping("/api/priests/{id}")
    public PriestResponse update(@PathVariable Long id, @Valid @RequestBody PriestRequest request) {
        return priestService.update(id, request);
    }

    @DeleteMapping("/api/priests/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        priestService.delete(id);
    }
}
