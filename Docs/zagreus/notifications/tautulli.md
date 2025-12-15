# Tautulli

## Preparation

* Read through the main [Notifications](./) page
* Copy your device-based or user-based webhook URL from Zagreus

## Setup the Webhook

In Tautulli's web GUI, head to Settings -> Notification Agents, hit the "Add a new notification agent" button and select "Zagreus". Please follow each section below to setup the webhook:

{% tabs %}
{% tab title="Configuration" %}
**Zagreus Webhook URL**

Paste the full device-based or user-based URL that was copied from Zagreus.

**Zagreus Profile**

Enter in the name of the profile which should be an **exact match** to the profile that this module instance was added to within Zagreus. Capitalization and punctuation _does_ matter.

{% hint style="warning" %}
This step is only required if you are _**not**_ using the default Zagreus profile (`default`). Zagreus will assume the default profile when none is supplied.

Correctly setting up this field is critically important to get full deep-linking support.
{% endhint %}
{% endtab %}

{% tab title="Triggers" %}
Select which events should trigger a push notification. The following triggers are supported:

|            Trigger           | Supported? |
| :--------------------------: | :--------: |
|        Playback Start        |      ✅     |
|         Playback Stop        |      ✅     |
|        Playback Pause        |      ✅     |
|        Playback Resume       |      ✅     |
|        Playback Error        |      ✅     |
|   Transcode Decision Change  |      ✅     |
|            Watched           |      ✅     |
|        Buffer Warning        |      ✅     |
|    User Concurrent Streams   |      ✅     |
|        User New Device       |      ✅     |
|        Recently Added        |      ✅     |
|       Plex Server Down       |      ✅     |
|      Plex Server Back Up     |      ✅     |
|    Plex Remote Access Down   |      ✅     |
|  Plex Remote Access Back Up  |      ✅     |
|     Plex Update Available    |      ✅     |
|   Tautulli Update Available  |      ✅     |
| Tautulli Database Corruption |      ✅     |
{% endtab %}

{% tab title="Conditions" %}
You can _**optionally**_ add conditions that must be met for the webhook notifications to trigger.

You can set as many conditions as you like, and can combine different conditions for different triggers by adding separate webhooks to Tautulli.
{% endtab %}

{% tab title="Text" %}
A default message is set for all trigger types, but on this page you can alter the exact text that would appear in the message.

Please read the top of this tab in Tautulli about how to utilize the different modifiers.
{% endtab %}
{% endtabs %}

Once setup, close Zagreus and run the webhook test in Tautulli. You should receive a new notification letting you know that Zagreus is ready to receive Tautulli notifications!

## Attach Images to Notifications

This step is **optional** but recommended. Unlike other modules, in order to receive the actual images (posters, etc.) instead of a generic poster along with the notification, you will need to setup an image host within Tautulli.

1. Go to Tautulli's web GUI
2. Open the Settings, enter "3rd Party APIs"
3. Select any of the available image providers
4. Follow the [3rd Party APIs Guide](https://github.com/Tautulli/Tautulli/wiki/3rd-Party-APIs-Guide) to acquire the required details for the chosen image provider
5. Enter and save the acquired API/Client ID information

{% hint style="info" %}
_If selecting `Self-hosted on public domain` as the image provider, ensure that the image path (_`/tautulli/image`) is publicly accessible from the internet
{% endhint %}
