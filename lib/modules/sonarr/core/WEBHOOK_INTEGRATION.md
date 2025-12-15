# Sonarr Webhook Integration

## Overview
Zagreus automatically injects webhooks into Sonarr instances to receive notifications for various events like episode downloads, grabs, and health checks.

## How It Works

1. **Automatic Injection**: When a Sonarr profile is loaded, Zagreus automatically creates or updates a webhook named "Zagreus" in the Sonarr instance.

2. **User-Specific URLs**: Each webhook URL includes the Supabase user ID to route notifications to the correct user:
   ```
   https://zagreus-notifications.fly.dev/v1/sonarr/user/{userID}
   ```

3. **Event Types**: The webhook is configured to trigger on:
   - Episode grabbed (onGrab)
   - Episode downloaded (onDownload) 
   - Episode upgraded (onUpgrade)
   - Episode renamed (onRename)
   - Series added (onSeriesAdd)
   - Series deleted (onSeriesDelete)
   - Episode file deleted (onEpisodeFileDelete)
   - Episode file deleted for upgrade (onEpisodeFileDeleteForUpgrade)
   - Health issues (onHealthIssue)
   - Manual interaction required (onManualInteractionRequired)

## Testing

To test the webhook integration:

1. Open the Sonarr module in Zagreus
2. Navigate to the "More" tab
3. Tap "Test Webhook"
4. The app will:
   - Create/update the webhook if needed
   - Send a test notification to your Sonarr instance
   - Display success or error message

## Implementation Details

### SonarrWebhookManager (`webhook_manager.dart`)
- `syncWebhook()`: Creates or updates the Zagreus webhook
- `getZagreusWebhook()`: Retrieves existing Zagreus webhook
- `removeWebhook()`: Removes the Zagreus webhook
- `testWebhook()`: Tests the webhook connection

### SonarrState (`state.dart`)
- Automatically calls `_syncWebhook()` when a profile is loaded
- Ensures webhooks are always up-to-date with the latest configuration

### Notification Model (`notification.dart`)
- `SonarrNotification.webhook()`: Factory method to create webhook configuration
- Includes all required fields for Sonarr webhook API

## Future Enhancements
- Add webhook management UI in settings
- Support for custom webhook events selection
- Webhook signature/authentication support