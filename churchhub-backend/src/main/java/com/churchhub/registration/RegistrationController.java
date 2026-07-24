package com.churchhub.registration;

import com.churchhub.common.PageResponse;
import com.churchhub.registration.dto.AdminRegistrationResponse;
import com.churchhub.registration.dto.ApproveRegistrationRequest;
import com.churchhub.registration.dto.RegisterAdminRequest;
import com.churchhub.registration.dto.RejectRegistrationRequest;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/registrations")
@RequiredArgsConstructor
public class RegistrationController {

    private final RegistrationService registrationService;

    /** Public: anyone may submit a PARISH_ADMIN sign-up request (rate-limited per client IP). */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AdminRegistrationResponse register(@Valid @RequestBody RegisterAdminRequest request,
                                              HttpServletRequest servletRequest) {
        return registrationService.register(request, servletRequest.getRemoteAddr());
    }

    @GetMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public PageResponse<AdminRegistrationResponse> list(
            @RequestParam(required = false) RegistrationStatus status,
            @ParameterObject @PageableDefault(size = 20) Pageable pageable) {
        return registrationService.list(status, pageable);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public AdminRegistrationResponse get(@PathVariable Long id) {
        return registrationService.get(id);
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public AdminRegistrationResponse approve(@PathVariable Long id,
                                             @Valid @RequestBody ApproveRegistrationRequest request) {
        return registrationService.approve(id, request);
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public AdminRegistrationResponse reject(@PathVariable Long id,
                                            @Valid @RequestBody RejectRegistrationRequest request) {
        return registrationService.reject(id, request);
    }
}
