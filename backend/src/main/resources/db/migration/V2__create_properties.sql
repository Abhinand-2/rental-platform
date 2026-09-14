CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL,

    title VARCHAR(200) NOT NULL,
    description TEXT,

    type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,

    address_line VARCHAR(500) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),

    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),

    bedrooms INTEGER,
    bathrooms INTEGER,

    area_sq_ft DECIMAL(12,2),

    monthly_rent NUMERIC(12,2),
    security_deposit NUMERIC(12,2),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_properties_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id),

    CONSTRAINT chk_properties_type
        CHECK (
            type IN (
                'APARTMENT',
                'HOUSE',
                'VILLA',
                'STUDIO',
                'PG',
                'OTHER'
            )
        ),

    CONSTRAINT chk_properties_status
        CHECK (
            status IN (
                'PENDING_APPROVAL',
                'APPROVED',
                'REJECTED',
                'PUBLISHED',
                'RENTED',
                'INACTIVE'
            )
        ),

    CONSTRAINT chk_properties_bedrooms
        CHECK (
            bedrooms IS NULL OR bedrooms >= 0
        ),

    CONSTRAINT chk_properties_bathrooms
        CHECK (
            bathrooms IS NULL OR bathrooms >= 0
        ),

    CONSTRAINT chk_properties_area
        CHECK (
            area_sq_ft IS NULL OR area_sq_ft > 0
        ),

    CONSTRAINT chk_properties_monthly_rent
        CHECK (
            monthly_rent IS NULL OR monthly_rent >= 0
        ),

    CONSTRAINT chk_properties_security_deposit
        CHECK (
            security_deposit IS NULL OR security_deposit >= 0
        ),

    CONSTRAINT chk_properties_latitude
        CHECK (
            latitude IS NULL OR latitude BETWEEN -90 AND 90
        ),

    CONSTRAINT chk_properties_longitude
        CHECK (
            longitude IS NULL OR longitude BETWEEN -180 AND 180
        )
);

CREATE INDEX idx_properties_owner_id
    ON properties(owner_id);

CREATE INDEX idx_properties_status
    ON properties(status);

CREATE INDEX idx_properties_city
    ON properties(city);

CREATE INDEX idx_properties_type
    ON properties(type);

CREATE INDEX idx_properties_owner_status
    ON properties(owner_id, status);