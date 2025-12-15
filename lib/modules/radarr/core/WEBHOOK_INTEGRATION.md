# Radarr Webhook Integration

## Overview
Zagreus automatically injects webhooks into Radarr instances to receive notifications for various events like movie downloads, grabs, and health checks.

## How It Works

1. **Automatic Injection**: When a Radarr profile is loaded, Zagreus automatically creates or updates a webhook named "Zagreus" in the Radarr instance.

2. **User-Specific URLs**: Each webhook URL includes the Supabase user ID to route notifications to the correct user:
   ```
   https://zagreus-notifications.fly.dev/v1/radarr/user/{userID}
   ```

3. **Event Types**: The webhook is configured to trigger on:
   - Movie grabbed (onGrab)
   - Movie downloaded (onDownload) 
   - Movie upgraded (onUpgrade)
   - Movie renamed (onRename)
   - Movie added (onMovieAdded)
   - Movie deleted (onMovieDelete)
   - Movie file deleted (onMovieFileDelete)
   - Movie file deleted for upgrade (onMovieFileDeleteForUpgrade)
   - Health issues (onHealthIssue)
   - Manual interaction required (onManualInteractionRequired)

## Testing

To test the webhook integration:

1. Open the Radarr module in Zagreus
2. Navigate to the "More" tab
3. Tap "Test Webhook"
4. The app will:
   - Create/update the webhook if needed
   - Send a test notification to your Radarr instance
   - Display success or error message

## Implementation Details

### RadarrWebhookManager (`webhook_manager.dart`)
- `syncWebhook()`: Creates or updates the Zagreus webhook
- `getZagreusWebhook()`: Retrieves existing Zagreus webhook
- `removeWebhook()`: Removes the Zagreus webhook
- `testWebhook()`: Tests the webhook connection

### RadarrState (`state.dart`)
- Automatically calls `_syncWebhook()` when a profile is loaded
- Ensures webhooks are always up-to-date with the latest configuration

### Notification Model (`notification.dart`)
- `RadarrNotification.webhook()`: Factory method to create webhook configuration
- Includes all required fields for Radarr webhook API

## Future Enhancements
- Add webhook management UI in settings
- Support for custom webhook events selection
- Webhook signature/authentication support