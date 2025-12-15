# Notifications

Many of the supported modules have support for webhooks, which we can utilize with the hosted notification relay to get rich, instant notifications with deep-linking support sent as push notifications directly to your devices running Zagreus!

{% hint style="info" %}
Push notifications are only available on Zagreus installations from official store releases.

On Android devices, Google Play Services must be installed on the device to receive notifications.
{% endhint %}

## Platform Support

Notifications are only supported on a limited set of platforms at this time because of the availability of Firebase tooling. As support for additional platforms are added to the tooling they will also be added to Zagreus!

|      Platform     | Supported? |
| :---------------: | :--------: |
|      Android      |      ✅     |
|        iOS        |      ✅     |
|       Linux       |      ❌     |
|       macOS       |      ✅     |
|    Web (Hosted)   |      ✅     |
| Web (Self-Hosted) |      ❌     |
|      Windows      |      ❌     |

## Module Support

|           Module          | Supported? | Deep Linking? |
| :-----------------------: | :--------: | :-----------: |
|    [Lidarr](lidarr.md)    |      ✅     |       ❌       |
|           NZBGet          |      ❌     |       ❌       |
| [Overseerr](overseerr.md) |      ✅     |       ❌       |
|    [Radarr](radarr.md)    |      ✅     |       ✅       |
|          SABnzbd          |      ❌     |       ❌       |
|    [Sonarr](sonarr.md)    |      ✅     |       ✅       |
|  [Tautulli](tautulli.md)  |      ✅     |       ✅       |

## Notification Types

Zagreus supports two different types of notifications: **User-Based** and **Device-Based**.

{% tabs %}
{% tab title="User-Based" %}
User-based notifications send notifications to all devices that are linked to your Zagreus account. Your device is automatically linked when you register or sign in to your account. This means that any current and future devices that are signed-in to your account will receive notifications automatically.
{% endtab %}

{% tab title="Device-Based" %}
Device-based notifications send notifications to a single, specific device. Device-based notifications do not require a Zagreus account, but require you to register every device as a new webhook in the module.
{% endtab %}
{% endtabs %}

## Getting Your Webhook URLs

To get the correct webhook URL for each module, simply head to the Settings within Zagreus, then into the "Notifications" page! The buttons on each module card will copy the **full, constructed webhook URL** to receive user-based or device-based notifications for that specific module. Please ensure to copy and use the correct webhook URL for each module, as mixing them up can lead to unexpected results.

{% hint style="warning" %}
**Do not publicly share your user-based or device-based URL!**

Anyone with access to your user or device webhook URLs can send notifications to your account or device.
{% endhint %}
