# Supabase Implementation for Zagreus

This directory contains the Supabase implementation that replaces Firebase functionality.

## Setup Instructions

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and anon key

### 2. Update Configuration

Edit `/lib/supabase/core.dart` and replace:
- `YOUR_SUPABASE_URL` with your project URL
- `YOUR_SUPABASE_ANON_KEY` with your anon key

### 3. Set Up Database

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `schema.sql`
4. Run the SQL to create tables and policies

### 4. Configure Authentication

1. In Supabase dashboard, go to Authentication > Settings
2. Enable email/password authentication
3. Configure email templates if needed

### 5. Storage Setup

The storage bucket for backups will be created automatically when you run the SQL schema.

## Migration from Firebase

### Authentication
- `ZagFirebaseAuth` → `ZagSupabaseAuth`
- Most methods have the same signatures
- Note: User deletion requires additional server-side implementation

### Database (Firestore → Supabase Database)
- `ZagFirebaseFirestore` → `ZagSupabaseFirestore`
- Uses PostgreSQL tables instead of NoSQL documents
- Same method signatures maintained

### Storage
- `ZagFirebaseStorage` → `ZagSupabaseStorage`
- Uses Supabase Storage buckets
- Same upload/download interfaces

### Messaging (FCM → APNS)
- `ZagFirebaseMessaging` → `ZagSupabaseMessaging`
- Requires native iOS APNS implementation
- Current implementation provides interface compatibility

## Required Database Tables

1. **backups**: Stores backup metadata
   - id (text, primary key)
   - user_id (uuid, foreign key)
   - title (text)
   - description (text)
   - timestamp (bigint)

2. **user_devices**: Stores device tokens for push notifications
   - id (uuid, primary key)
   - user_id (uuid, foreign key)
   - device_token (text)
   - device_type (text)

## Security

- Row Level Security (RLS) is enabled on all tables
- Users can only access their own data
- Storage policies ensure users can only access their own backups

## TODOs

1. Implement proper APNS integration for iOS push notifications
2. Add server-side function for user deletion
3. Consider adding real-time subscriptions for backup syncing
4. Add error handling for network connectivity issues