package com.churchhub.parish.dto;

import com.churchhub.massschedule.dto.MassScheduleRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record ParishRequest(
        @NotBlank @Size(max = 255) String name,
        @Size(max = 500) String address,
        @Pattern(regexp = "^(0\\d{9})?$", message = "Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0")
        String phone,
        @DecimalMin("-90.0") @DecimalMax("90.0") BigDecimal latitude,
        @DecimalMin("-180.0") @DecimalMax("180.0") BigDecimal longitude,
        String description,
        Boolean isActive,
        /**
         * Giờ lễ kèm theo khi tạo nhà thờ. Mỗi mục dùng dayType (WEEKDAY = ngày thường,
         * SUNDAY = Chúa nhật/cuối tuần, SPECIAL = lễ trọng) và dayOfWeek (1=Thứ Hai .. 7=Chúa nhật)
         * để phân biệt giờ lễ các ngày trong tuần và cuối tuần. Chỉ áp dụng khi tạo mới.
         */
        @Valid List<MassScheduleRequest> massSchedules
) {
}
