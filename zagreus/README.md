# Zagreus

Zagreus is a self-hosted media controller for Sonarr/Radarr/Lidarr and friends. It is a modern fork of LunaSea with a new auth stack, refreshed UI, and extra tooling for power users.

## Highlights

- Supabase auth (replaces Firebase) and APNS-first iOS notifications; FaceID/passcode lock; Siri shortcuts
- Refined theming (AMOLED + optional LunaSea theme) and legibility tweaks
- Backups, profile switching, webhook-driven notifications, and real-time in-app toasts
- Integrated search (Newznab/NZBHydra2), download queue, swipeable module tabs, and the new download drawer
- Tiered experience: Pro/Mega/Ultra with Z Agent, Deep Cuts, Magic sections, Pro Sharing, and yearly pricing
- Enhanced discovery: batch ops, relevancy-ranked results, sortable sections, improved links (rent/buy, deep links), Up Next and widgets

## Supported Services

- Lidarr, Radarr, Sonarr
- Readarr, Overseerr, Prowlarr, NZBGet, SABnzbd
- Newznab/NZBHydra2 searching and Overseerr notifications
- Tautulli analytics (with optional syncing for Z), server module, Wake-on-LAN

## Prerequisites

- Flutter stable (3.x or newer recommended)
- Dart SDK (ships with Flutter)
- Xcode + CocoaPods for iOS builds
- A Supabase project (keys provided via env/Flavor config)

## Getting Started

Clone and bootstrap:

```bash
flutter pub get
flutter run
```

Common tips:
- Create a `lib/environment.dart` or flavor file with your Supabase keys and API endpoints.
- For push notifications, deploy the companion service in `../zagreus-notification-service`.
- Use a real device or iOS simulator with APNS configured to exercise notifications.

## What's New (1.1–1.7)

- Notification upgrades: no-account support, granular controls, posters, and live toasts.
- Discover enhancements: batch operations, relevancy-ranked results, sortable sections, better links/deep links, UI fixes, and speed cube.
- New modules and integrations: Readarr, Prowlarr, Overseerr module + notifications, server module (Pro).
- UX and control: swipe between tabs, download drawer, slow mode for busy servers, watch history sync fixes, enhanced add links, better movie detail links.
- Media intelligence (Pro+): TMDB/IMDb/RT/Metacritic ratings, rent/buy deep links, trailers on long press, Up Next, Deep Cuts, Magic Show/Movie/Cast & Crew sections.
- Access and security: FaceID/password lock, Siri shortcuts, SSID-based local/remote switching, yearly pricing, Pro Sharing (1 for Mega, 5 for Ultra).
- Visual polish: legibility passes, optional LunaSea theme, calendar defaults to 2 rows, dashboard search styling, widgets for upcoming content.

## Testing

Run static checks and unit tests:

```bash
flutter analyze
flutter test
```

## Notifications

Push/webhook handling lives in a separate service. See `../zagreus-notification-service` for deployment and configuration.

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

## Copyright

Copyright (C) 2025 Zebrra Labs LLC.

This program is a fork of LunaSea, originally created by Jagandeep Brar. It is provided without warranty; see the GPLv3 for details.

## Contact

- [Email](mailto:hello@zagreus.app)
- [Website](https://www.zagreus.app)
