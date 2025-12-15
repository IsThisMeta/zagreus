-- Supabase Database Schema for Zagreus

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create backups table
CREATE TABLE IF NOT EXISTS backups (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    timestamp BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_devices table for storing device tokens
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_token TEXT NOT NULL,
    device_type TEXT DEFAULT 'ios',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, device_token)
);

-- Create indexes for better performance
CREATE INDEX idx_backups_user_id ON backups(user_id);
CREATE INDEX idx_backups_timestamp ON backups(user_id, timestamp DESC);
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);

-- Enable Row Level Security
ALTER TABLE backups ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Create policies for backups table
CREATE POLICY "Users can view own backups" ON backups
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own backups" ON backups
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own backups" ON backups
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own backups" ON backups
    FOR DELETE USING (auth.uid() = user_id);

-- Create policies for user_devices table
CREATE POLICY "Users can view own devices" ON user_devices
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own devices" ON user_devices
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own devices" ON user_devices
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own devices" ON user_devices
    FOR DELETE USING (auth.uid() = user_id);

-- Create storage bucket for backups
INSERT INTO storage.buckets (id, name, public)
VALUES ('backups', 'backups', false);

-- Create storage policies
CREATE POLICY "Users can upload own backups" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'backups' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own backups" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'backups' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update own backups" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'backups' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own backups" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'backups' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for backups table
CREATE TRIGGER update_backups_updated_at BEFORE UPDATE ON backups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for user_devices table
CREATE TRIGGER update_user_devices_last_seen_at BEFORE UPDATE ON user_devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();