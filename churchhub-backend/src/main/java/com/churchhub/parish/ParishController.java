package com.churchhub.parish;

import com.churchhub.common.PageResponse;
import com.churchhub.parish.dto.ParishDetailResponse;
import com.churchhub.parish.dto.ParishRequest;
import com.churchhub.parish.dto.ParishResponse;
import com.churchhub.parish.dto.SetParishAdminsRequest;
import com.churchhub.user.UserService;
import com.churchhub.user.dto.UserResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/parishes")
@RequiredArgsConstructor
public class ParishController {

    private final ParishService parishService;
    private final UserService userService;

    @GetMapping
    public PageResponse<ParishResponse> search(
            @RequestParam(required = false) String name,
            @PageableDefault(size = 20) Pageable pageable) {
        return parishService.search(name, pageable);
    }

    @GetMapping("/{slug}")
    public ParishDetailResponse getBySlug(@PathVariable String slug) {
        return parishService.getBySlug(slug);
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public ParishDetailResponse create(@Valid @RequestBody ParishRequest request) {
        return parishService.create(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'PARISH_ADMIN')")
    public ParishResponse update(@PathVariable Long id, @Valid @RequestBody ParishRequest request) {
        // Ownership (PARISH_ADMIN -> own parish only) is enforced in the service.
        return parishService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        parishService.delete(id);
    }

    @GetMapping("/{id}/admins")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public List<UserResponse> listAdmins(@PathVariable Long id) {
        return userService.listAdminsByParish(id);
    }

    @PutMapping("/{id}/admins")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public List<UserResponse> setAdmins(
            @PathVariable Long id,
            @Valid @RequestBody SetParishAdminsRequest request) {
        return userService.setParishAdmins(id, request.userIds());
    }
}
