# Zagreus Notification Service (APNs Version)

A TypeScript backend service that handles receiving webhooks from Radarr/Sonarr and sends push notifications via Apple Push Notification service (APNs) to iOS devices.

## Architecture

This service:
1. Receives webhooks from Radarr/Sonarr at `/v1/notifications/webhook`
2. Registers iOS device tokens at `/v1/auth/register`
3. Stores user and device information in PostgreSQL
4. Sends push notifications via APNs when webhook events occur

## Environment Variables

| Variable               | Description                                           | Required |
|:----------------------|:-----------------------------------------------------|:--------:|
| `APNS_AUTH_KEY`       | APNs authentication key content (.p8 file)           | ✓ |
| `APNS_KEY_ID`         | APNs Key ID (from Apple Developer)                  | ✓ |
| `APNS_TEAM_ID`        | Apple Developer Team ID                             | ✓ |
| `DB_HOST`             | PostgreSQL host                                      | ✓ |
| `DB_PORT`             | PostgreSQL port                                      | ✓ |
| `DB_NAME`             | PostgreSQL database name                             | ✓ |
| `DB_USER`             | PostgreSQL username                                  | ✓ |
| `DB_PASSWORD`         | PostgreSQL password                                  | ✓ |
| `REDIS_HOST`          | Redis host for caching                              | ✓ |
| `REDIS_PORT`          | Redis port                                           | ✓ |
| `REDIS_USER`          | Redis username                                       |   |
| `REDIS_PASS`          | Redis password                                       |   |
| `REDIS_USE_TLS`       | Use TLS for Redis connection                        |   |
| `FANART_TV_API_KEY`   | Fanart.tv API key (for rich notifications)         |   |
| `THEMOVIEDB_API_KEY`  | TMDB API key (for rich notifications)               |   |
| `PORT`                | Service port (default: 9000)                        |   |
| `NODE_ENV`            | Environment (development/production)                 |   |

## API Endpoints

### POST /v1/auth/register
Register a device for push notifications.

```json
{
  "user_id": "supabase-user-id",
  "email": "user@example.com",
  "token": "64-character-apns-token",
  "device_name": "iPhone",
  "device_model": "iPhone 14 Pro",
  "os_version": "17.2",
  "app_version": "1.0.0"
}
```

### POST /v1/auth/unregister
Unregister a device token.

```json
{
  "token": "64-character-apns-token"
}
```

### POST /v1/notifications/webhook
Receive webhooks from Radarr/Sonarr. The service automatically detects the source based on payload structure.

Required fields in payload:
- `user_id`: The Supabase user ID
- `eventType`: The type of event (Download, Grab, Health, etc.)
- Service-specific data (movie/series information)

## Database Setup

Run the SQL schema in `src/services/database/schema.sql` to create the required tables:
- `users`: Stores user information
- `device_tokens`: Stores APNs device tokens
- `notification_settings`: User notification preferences
- `failed_notifications`: Failed notification log for debugging

## Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up PostgreSQL database and run schema

3. Configure environment variables in `.env`

4. Start development server:
   ```bash
   npm start
   ```

## Production Deployment

1. Build the TypeScript:
   ```bash
   npm run build
   ```

2. Start production server:
   ```bash
   npm run serve
   ```

## Docker Deployment

```bash
docker build -t zagreus-notification-service .
docker run -d \
  --env-file .env \
  -p 9000:9000 \
  zagreus-notification-service
```

## Webhook Configuration in Zagreus App

The Zagreus app automatically configures webhooks in Radarr/Sonarr with:
- URL: `https://your-domain.com/v1/notifications/webhook`
- Method: POST
- Events: All notification types enabled

The webhook payload includes the user_id from Supabase authentication.