# Zagreus

Zagreus is a self-hosted media controller for Sonarr/Radarr/Lidarr and friends. It is a modern fork of LunaSea with a new auth stack, refreshed UI, and extra tooling for power users.

## Highlights

- Supabase auth (replaces Firebase) and APNS-first iOS notifications
- Refined theming and AMOLED option
- Backups, profile switching, and webhook-driven notifications
- Integrated search (Newznab/NZBHydra2), download queue, and module drawers

## Supported Services

- Lidarr, Radarr, Sonarr
- NZBGet, SABnzbd
- Newznab/NZBHydra2 searching
- Tautulli analytics
- Wake-on-LAN

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
