CREATE TABLE rent_charges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    lease_id UUID NOT NULL,

    billing_year INTEGER NOT NULL,
    billing_month INTEGER NOT NULL,

    amount NUMERIC(12,2) NOT NULL,
    due_date DATE NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rent_charges_lease
        FOREIGN KEY (lease_id)
        REFERENCES leases(id),

    CONSTRAINT uq_rent_charge_billing_period
        UNIQUE (lease_id, billing_year, billing_month),

    CONSTRAINT chk_rent_charge_month
        CHECK (billing_month BETWEEN 1 AND 12),

    CONSTRAINT chk_rent_charge_year
        CHECK (billing_year >= 2000),

    CONSTRAINT chk_rent_charge_amount
        CHECK (amount > 0),

    CONSTRAINT chk_rent_charge_status
        CHECK (
            status IN (
                'PENDING',
                'PAID',
                'OVERDUE',
                'CANCELLED'
            )
        )
);

CREATE INDEX idx_rent_charges_lease_id
    ON rent_charges(lease_id);

CREATE INDEX idx_rent_charges_status
    ON rent_charges(status);

CREATE INDEX idx_rent_charges_due_date
    ON rent_charges(due_date);


CREATE TABLE rent_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    rent_charge_id UUID NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    paid_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    payment_reference VARCHAR(100),

    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rent_payments_charge
        FOREIGN KEY (rent_charge_id)
        REFERENCES rent_charges(id),

    CONSTRAINT uq_rent_payment_charge
        UNIQUE (rent_charge_id),

    CONSTRAINT chk_rent_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_rent_payment_status
        CHECK (
            status IN (
                'SUCCESS',
                'FAILED'
            )
        )
);

CREATE INDEX idx_rent_payments_charge_id
    ON rent_payments(rent_charge_id);

CREATE INDEX idx_rent_payments_status
    ON rent_payments(status);