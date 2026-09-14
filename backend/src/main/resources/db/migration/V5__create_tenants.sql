
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tenants_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT uq_tenants_user
        UNIQUE (user_id)
);

CREATE INDEX idx_tenants_user_id
    ON tenants(user_id);

