
CREATE TABLE leases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rental_request_id UUID NOT NULL,
    property_id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    owner_id UUID NOT NULL,

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    monthly_rent NUMERIC(12,2) NOT NULL,
    security_deposit NUMERIC(12,2),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_leases_rental_request
        FOREIGN KEY (rental_request_id)
        REFERENCES rental_requests(id),

    CONSTRAINT fk_leases_property
        FOREIGN KEY (property_id)
        REFERENCES properties(id),

    CONSTRAINT fk_leases_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(id),

    CONSTRAINT fk_leases_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id),

    CONSTRAINT uq_leases_rental_request
        UNIQUE (rental_request_id),

    CONSTRAINT chk_leases_status
        CHECK (
            status IN (
                'DRAFT',
                'ACTIVE',
                'EXPIRED',
                'TERMINATED',
                'CANCELLED'
            )
        ),

    CONSTRAINT chk_leases_dates
        CHECK (end_date > start_date),

    CONSTRAINT chk_leases_monthly_rent
        CHECK (monthly_rent > 0),

    CONSTRAINT chk_leases_security_deposit
        CHECK (security_deposit IS NULL OR security_deposit >= 0)
);

CREATE INDEX idx_leases_property_id
    ON leases(property_id);

CREATE INDEX idx_leases_tenant_id
    ON leases(tenant_id);

CREATE INDEX idx_leases_owner_id
    ON leases(owner_id);

CREATE INDEX idx_leases_status
    ON leases(status);

CREATE INDEX idx_leases_property_status
    ON leases(property_id, status);

CREATE INDEX idx_leases_tenant_status
    ON leases(tenant_id, status);

CREATE UNIQUE INDEX uq_active_lease_per_property
    ON leases(property_id)
    WHERE status = 'ACTIVE';

