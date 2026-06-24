package com.churchhub.common;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import org.hibernate.annotations.Generated;
import org.hibernate.generator.EventType;

import java.time.OffsetDateTime;

/**
 * created_at / updated_at are owned by the database (DEFAULT now() + the
 * set_updated_at() trigger). They are read-only from the JPA side and
 * re-fetched after insert/update so the entity stays in sync.
 */
@Getter
@MappedSuperclass
public abstract class BaseEntity {

    @Generated(event = EventType.INSERT)
    @Column(name = "created_at", insertable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Generated(event = {EventType.INSERT, EventType.UPDATE})
    @Column(name = "updated_at", insertable = false, updatable = false)
    private OffsetDateTime updatedAt;
}
