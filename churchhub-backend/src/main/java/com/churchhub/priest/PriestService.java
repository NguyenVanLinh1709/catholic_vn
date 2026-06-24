package com.churchhub.priest;

import com.churchhub.common.NotFoundException;
import com.churchhub.parish.ParishRepository;
import com.churchhub.priest.dto.PriestRequest;
import com.churchhub.priest.dto.PriestResponse;
import com.churchhub.security.ParishAccessGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PriestService {

    private final PriestRepository priestRepository;
    private final ParishRepository parishRepository;
    private final ParishAccessGuard parishAccess;

    @Transactional(readOnly = true)
    public List<PriestResponse> listByParish(Long parishId) {
        requireParish(parishId);
        return priestRepository.findByParishIdOrderByOrderIndexAscIdAsc(parishId).stream()
                .map(PriestResponse::from)
                .toList();
    }

    @Transactional
    public PriestResponse create(Long parishId, PriestRequest request) {
        requireParish(parishId);
        parishAccess.assertCanManage(parishId);

        Priest priest = Priest.builder()
                .parishId(parishId)
                .fullName(request.fullName())
                .role(request.role())
                .phone(request.phone())
                .photoUrl(request.photoUrl())
                .orderIndex(request.orderIndex() == null ? 0 : request.orderIndex())
                .build();
        return PriestResponse.from(priestRepository.save(priest));
    }

    @Transactional
    public PriestResponse update(Long id, PriestRequest request) {
        Priest priest = getPriest(id);
        parishAccess.assertCanManage(priest.getParishId());

        priest.setFullName(request.fullName());
        priest.setRole(request.role());
        priest.setPhone(request.phone());
        priest.setPhotoUrl(request.photoUrl());
        if (request.orderIndex() != null) {
            priest.setOrderIndex(request.orderIndex());
        }
        return PriestResponse.from(priestRepository.save(priest));
    }

    @Transactional
    public void delete(Long id) {
        Priest priest = getPriest(id);
        parishAccess.assertCanManage(priest.getParishId());
        priestRepository.delete(priest);
    }

    private Priest getPriest(Long id) {
        return priestRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Priest", id));
    }

    private void requireParish(Long parishId) {
        if (!parishRepository.existsById(parishId)) {
            throw NotFoundException.of("Parish", parishId);
        }
    }
}
