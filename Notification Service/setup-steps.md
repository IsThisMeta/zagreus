# Zagreus Notification Setup Steps

Since there are no existing users, we can skip migration and build fresh!

## Step 1: Flutter App - Add Supabase Auth

1. Add Supabase to pubspec.yaml:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

2. Initialize Supabase in main.dart:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

3. Add auth screens (login/register)
4. On successful auth, register APNS token to Supabase

## Step 2: Update Notification Service

1. Remove all Firebase code
2. Add Supabase client
3. Update to use APNS instead of FCM

## Step 3: Deploy to Fly.io

1. Create fly.toml
2. Add environment variables
3. Deploy!

No migration needed - just build it fresh with Supabase from the start!