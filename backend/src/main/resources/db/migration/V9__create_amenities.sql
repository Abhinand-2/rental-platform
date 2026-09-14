CREATE TABLE amenities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_amenities_name UNIQUE (name)
);

CREATE TABLE property_amenities (
    property_id UUID NOT NULL,
    amenity_id UUID NOT NULL,

    CONSTRAINT pk_property_amenities
        PRIMARY KEY (property_id, amenity_id),

    CONSTRAINT fk_property_amenities_property
        FOREIGN KEY (property_id)
        REFERENCES properties(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_property_amenities_amenity
        FOREIGN KEY (amenity_id)
        REFERENCES amenities(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_property_amenities_property_id
    ON property_amenities(property_id);

CREATE INDEX idx_property_amenities_amenity_id
    ON property_amenities(amenity_id);