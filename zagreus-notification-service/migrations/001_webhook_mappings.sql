-- Create webhook_mappings table for 6-character webhook IDs
CREATE TABLE IF NOT EXISTS webhook_mappings (
    webhook_id VARCHAR(6) PRIMARY KEY,
    user_id UUID,  -- NULL for anonymous devices
    device_tokens TEXT[],  -- Array of APNS tokens
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index for user lookups
CREATE INDEX IF NOT EXISTS idx_webhook_mappings_user_id
ON webhook_mappings(user_id)
WHERE user_id IS NOT NULL;

-- Index for anonymous lookups
CREATE INDEX IF NOT EXISTS idx_webhook_mappings_anonymous
ON webhook_mappings(is_anonymous)
WHERE is_anonymous = TRUE;