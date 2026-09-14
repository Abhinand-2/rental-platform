CREATE TABLE rental_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    property_id UUID NOT NULL,
    applicant_user_id UUID NOT NULL,

    message TEXT,
    requested_start_date DATE NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rental_requests_property
        FOREIGN KEY (property_id)
        REFERENCES properties(id),

    CONSTRAINT fk_rental_requests_applicant
        FOREIGN KEY (applicant_user_id)
        REFERENCES users(id),

    CONSTRAINT chk_rental_requests_status
        CHECK (
            status IN (
                'PENDING',
                'APPROVED',
                'REJECTED',
                'CANCELLED'
            )
        )
);

CREATE INDEX idx_rental_requests_property_id
    ON rental_requests(property_id);

CREATE INDEX idx_rental_requests_applicant_user_id
    ON rental_requests(applicant_user_id);

CREATE INDEX idx_rental_requests_status
    ON rental_requests(status);

CREATE INDEX idx_rental_requests_property_status
    ON rental_requests(property_id, status);

CREATE INDEX idx_rental_requests_applicant_status
    ON rental_requests(applicant_user_id, status);