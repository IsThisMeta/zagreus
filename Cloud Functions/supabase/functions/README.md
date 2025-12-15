# Supabase Edge Functions for Zagreus

## Setup

1. **Get your Apple Shared Secret**:
   - Go to App Store Connect
   - Navigate to your app → In-App Purchases → Manage
   - Find "App-Specific Shared Secret" and generate one
   - Copy the secret

2. **Deploy the Edge Function**:
   ```bash
   supabase functions deploy validate-receipt
   ```

3. **Set the environment variable**:
   ```bash
   supabase secrets set APPLE_SHARED_SECRET="your-shared-secret-here"
   ```

4. **Run the migration**:
   ```bash
   supabase db push
   ```

## How it works

1. **Purchase Flow**:
   - User purchases in app
   - App receives receipt from Apple
   - App sends receipt to Edge Function
   - Edge Function validates with Apple
   - Valid receipts stored in database
   - App checks database for Pro status

2. **Restore Flow**:
   - App first checks database for existing subscription
   - If found and valid, restores Pro
   - Otherwise falls back to Apple restore

3. **Status Check**:
   - App checks database for active subscription
   - Falls back to local storage if offline
   - Caches result for 5 minutes

## Benefits

- **Cross-device sync**: Pro status syncs across all devices
- **Server validation**: Prevents receipt fraud
- **Analytics ready**: Can query subscription data
- **Offline support**: Falls back to local storage
- **Auto-expiry**: Database checks expiry dates

## Testing

1. **TestFlight/Sandbox**:
   - Receipts automatically validate against sandbox
   - Status 21007 triggers sandbox validation

2. **Production**:
   - Validates against production first
   - Real money transactions

## Monitoring

Check subscription status:
```sql
SELECT * FROM subscriptions WHERE user_id = 'user-id-here';
```

Active subscriptions:
```sql
SELECT COUNT(*) FROM subscriptions
WHERE status = 'active'
AND expires_date > NOW();
```