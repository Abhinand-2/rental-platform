CREATE TABLE property_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    property_id UUID NOT NULL,

    image_url VARCHAR(1000) NOT NULL,

    display_order INTEGER NOT NULL DEFAULT 0,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_property_images_property
        FOREIGN KEY (property_id)
        REFERENCES properties(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_property_images_display_order
        CHECK (display_order >= 0),

    CONSTRAINT uq_property_images_order
        UNIQUE (property_id, display_order)
);

CREATE INDEX idx_property_images_property_id
    ON property_images(property_id);

CREATE UNIQUE INDEX uq_property_images_primary
    ON property_images(property_id)
    WHERE is_primary = TRUE;