import 'package:flutter/material.dart';

import 'package:quick_actions/quick_actions.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/modules/unraid.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/dashboard/core/state.dart';
import 'package:zagreus/api/wake_on_lan/wake_on_lan.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

part 'modules.g.dart';

const MODULE_DASHBOARD_KEY = 'dashboard';
const MODULE_EXTERNAL_MODULES_KEY = 'external_modules';
const MODULE_LIDARR_KEY = 'lidarr';
const MODULE_NZBGET_KEY = 'nzbget';
const MODULE_OVERSEERR_KEY = 'overseerr';
const MODULE_RADARR_KEY = 'radarr';
const MODULE_SABNZBD_KEY = 'sabnzbd';
const MODULE_SEARCH_KEY = 'search';
const MODULE_SETTINGS_KEY = 'settings';
const MODULE_SONARR_KEY = 'sonarr';
const MODULE_TAUTULLI_KEY = 'tautulli';
const MODULE_WAKE_ON_LAN_KEY = 'wake_on_lan';
const MODULE_DISCOVER_KEY = 'discover';
const MODULE_UNRAID_KEY = 'unraid';
const MODULE_READARR_KEY = 'readarr';
const MODULE_BAZARR_KEY = 'bazarr';

@HiveType(typeId: 25, adapterName: 'ZagModuleAdapter')
enum ZagModule {
  @HiveField(0)
  DASHBOARD(MODULE_DASHBOARD_KEY),
  @HiveField(11)
  EXTERNAL_MODULES(MODULE_EXTERNAL_MODULES_KEY),
  @HiveField(1)
  LIDARR(MODULE_LIDARR_KEY),
  @HiveField(2)
  NZBGET(MODULE_NZBGET_KEY),
  @HiveField(3)
  OVERSEERR(MODULE_OVERSEERR_KEY),
  @HiveField(4)
  RADARR(MODULE_RADARR_KEY),
  @HiveField(5)
  SABNZBD(MODULE_SABNZBD_KEY),
  @HiveField(6)
  SEARCH(MODULE_SEARCH_KEY),
  @HiveField(7)
  SETTINGS(MODULE_SETTINGS_KEY),
  @HiveField(8)
  SONARR(MODULE_SONARR_KEY),
  @HiveField(9)
  TAUTULLI(MODULE_TAUTULLI_KEY),
  @HiveField(10)
  WAKE_ON_LAN(MODULE_WAKE_ON_LAN_KEY),
  @HiveField(12)
  DISCOVER(MODULE_DISCOVER_KEY),
  @HiveField(13)
  UNRAID(MODULE_UNRAID_KEY),
  @HiveField(15)
  READARR(MODULE_READARR_KEY),
  @HiveField(16)
  BAZARR(MODULE_BAZARR_KEY);

  final String key;
  const ZagModule(this.key);

  static ZagModule? fromKey(String? key) {
    switch (key) {
      case MODULE_DASHBOARD_KEY:
        return ZagModule.DASHBOARD;
      case MODULE_LIDARR_KEY:
        return ZagModule.LIDARR;
      case MODULE_NZBGET_KEY:
        return ZagModule.NZBGET;
      case MODULE_RADARR_KEY:
        return ZagModule.RADARR;
      case MODULE_SABNZBD_KEY:
        return ZagModule.SABNZBD;
      case MODULE_SEARCH_KEY:
        return ZagModule.SEARCH;
      case MODULE_SETTINGS_KEY:
        return ZagModule.SETTINGS;
      case MODULE_SONARR_KEY:
        return ZagModule.SONARR;
      case MODULE_OVERSEERR_KEY:
        return ZagModule.OVERSEERR;
      case MODULE_TAUTULLI_KEY:
        return ZagModule.TAUTULLI;
      case MODULE_WAKE_ON_LAN_KEY:
        return ZagModule.WAKE_ON_LAN;
      case MODULE_EXTERNAL_MODULES_KEY:
        return ZagModule.EXTERNAL_MODULES;
      case MODULE_DISCOVER_KEY:
        return ZagModule.DISCOVER;
      case MODULE_UNRAID_KEY:
        return ZagModule.UNRAID;
      case MODULE_READARR_KEY:
        return ZagModule.READARR;
      case MODULE_BAZARR_KEY:
        return ZagModule.BAZARR;
    }
    return null;
  }

  static List<ZagModule> get active {
    return ZagModule.values.filter((m) {
      if (m == ZagModule.DASHBOARD) return false;
      if (m == ZagModule.SETTINGS) return false;
      if (m == ZagModule.BAZARR) return false; // Bazarr is integrated into Radarr/Sonarr
      return m.featureFlag;
    }).toList();
  }
}

extension ZagModuleEnablementExtension on ZagModule {
  bool get featureFlag {
    switch (this) {
      case ZagModule.OVERSEERR:
        return true;
      case ZagModule.WAKE_ON_LAN:
        return ZagWakeOnLAN.isSupported;
      case ZagModule.DISCOVER:
        return true;
      case ZagModule.UNRAID:
        return true;
      default:
        return true;
    }
  }

  bool get isEnabled {
    switch (this) {
      case ZagModule.DASHBOARD:
        return true;
      case ZagModule.SETTINGS:
        return true;
      case ZagModule.LIDARR:
        return ZagProfile.current.lidarrEnabled;
      case ZagModule.NZBGET:
        return ZagProfile.hasEnabledInstance('nzbget');
      case ZagModule.OVERSEERR:
        return ZagProfile.current.overseerrEnabled;
      case ZagModule.RADARR:
        return ZagProfile.current.radarrEnabled;
      case ZagModule.SABNZBD:
        return ZagProfile.hasEnabledInstance('sabnzbd');
      case ZagModule.SEARCH:
        // Search module is enabled if user has any indexers configured
        // Filtering between Prowlarr and regular indexers happens in the UI
        return !ZagBox.indexers.isEmpty;
      case ZagModule.SONARR:
        return ZagProfile.current.sonarrEnabled;
      case ZagModule.TAUTULLI:
        return ZagProfile.current.tautulliEnabled;
      case ZagModule.WAKE_ON_LAN:
        return ZagProfile.current.wakeOnLANEnabled;
      case ZagModule.EXTERNAL_MODULES:
        return !ZagBox.externalModules.isEmpty;
      case ZagModule.DISCOVER:
        return true;
      case ZagModule.UNRAID:
        return ZagProfile.current.unraidEnabled;
      case ZagModule.READARR:
        return ZagProfile.current.readarrEnabled;
      case ZagModule.BAZARR:
        return ZagProfile.current.bazarrEnabled;
    }
  }
}

extension ZagModuleMetadataExtension on ZagModule {
  String get title {
    switch (this) {
      case ZagModule.DASHBOARD:
        return 'zagreus.Dashboard'.tr();
      case ZagModule.LIDARR:
        return 'Lidarr';
      case ZagModule.NZBGET:
        return 'NZBGet';
      case ZagModule.RADARR:
        return 'Radarr';
      case ZagModule.SABNZBD:
        return 'SABnzbd';
      case ZagModule.SEARCH:
        return 'search.Search'.tr();
      case ZagModule.SETTINGS:
        return 'zagreus.Settings'.tr();
      case ZagModule.SONARR:
        return 'Sonarr';
      case ZagModule.TAUTULLI:
        return 'Tautulli';
      case ZagModule.OVERSEERR:
        return 'Overseerr';
      case ZagModule.WAKE_ON_LAN:
        return 'Wake on LAN';
      case ZagModule.EXTERNAL_MODULES:
        return 'zagreus.ExternalModules'.tr();
      case ZagModule.DISCOVER:
        return 'zagreus.Dashboard'.tr();
      case ZagModule.UNRAID:
        return 'Unraid';
      case ZagModule.READARR:
        return 'Readarr';
      case ZagModule.BAZARR:
        return 'Bazarr';
    }
  }

  IconData get icon {
    switch (this) {
      case ZagModule.DASHBOARD:
        return Icons.home_rounded;
      case ZagModule.LIDARR:
        return ZagIcons.LIDARR;
      case ZagModule.NZBGET:
        return ZagIcons.NZBGET;
      case ZagModule.RADARR:
        return ZagIcons.RADARR;
      case ZagModule.SABNZBD:
        return ZagIcons.SABNZBD;
      case ZagModule.SEARCH:
        return Icons.travel_explore_rounded;
      case ZagModule.SETTINGS:
        return Icons.settings_rounded;
      case ZagModule.SONARR:
        return ZagIcons.SONARR;
      case ZagModule.TAUTULLI:
        return ZagIcons.TAUTULLI;
      case ZagModule.OVERSEERR:
        return ZagIcons.OVERSEERR;
      case ZagModule.WAKE_ON_LAN:
        return Icons.settings_remote_rounded;
      case ZagModule.EXTERNAL_MODULES:
        return Icons.settings_ethernet_rounded;
      case ZagModule.DISCOVER:
        return Icons.home_rounded;
      case ZagModule.UNRAID:
        return ZagIcons.UNRAID;
      case ZagModule.READARR:
        return ZagIcons.READARR;
      case ZagModule.BAZARR:
        return Icons.subtitles_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ZagModule.DASHBOARD:
        return ZagColours.currentAccent;
      case ZagModule.LIDARR:
        return const Color(0xFF159552);
      case ZagModule.NZBGET:
        return const Color(0xFF42D535);
      case ZagModule.RADARR:
        return const Color(0xFFFEC333);
      case ZagModule.SABNZBD:
        return const Color(0xFFFECC2B);
      case ZagModule.SEARCH:
        return const Color(0xFF0087FF); // Prowlarr blue
      case ZagModule.SETTINGS:
        return ZagColours.currentAccent;
      case ZagModule.SONARR:
        return const Color(0xFF3FC6F4);
      case ZagModule.TAUTULLI:
        return const Color(0xFFDBA23A);
      case ZagModule.OVERSEERR:
        return const Color(0xFF6366F1);
      case ZagModule.WAKE_ON_LAN:
        return ZagColours.currentAccent;
      case ZagModule.EXTERNAL_MODULES:
        return ZagColours.currentAccent;
      case ZagModule.DISCOVER:
        return ZagColours.currentAccent;
      case ZagModule.UNRAID:
        return const Color(0xFFEA472B); // Updated Unraid brand orange
      case ZagModule.READARR:
        return const Color(0xFF8E2222); // Readarr red (142, 34, 34)
      case ZagModule.BAZARR:
        return const Color(0xFFFFB949); // Bazarr yellow/orange
    }
  }

  String? get website {
    switch (this) {
      case ZagModule.DASHBOARD:
        return null;
      case ZagModule.LIDARR:
        return 'https://lidarr.audio';
      case ZagModule.NZBGET:
        return 'https://nzbget.net';
      case ZagModule.RADARR:
        return 'https://radarr.video';
      case ZagModule.SABNZBD:
        return 'https://sabnzbd.org';
      case ZagModule.SEARCH:
        return null;
      case ZagModule.SETTINGS:
        return null;
      case ZagModule.SONARR:
        return 'https://sonarr.tv';
      case ZagModule.TAUTULLI:
        return 'https://tautulli.com';
      case ZagModule.OVERSEERR:
        return 'https://overseerr.dev';
      case ZagModule.WAKE_ON_LAN:
        return null;
      case ZagModule.EXTERNAL_MODULES:
        return null;
      case ZagModule.DISCOVER:
        return null;
      case ZagModule.UNRAID:
        return 'https://unraid.net';
      case ZagModule.READARR:
        return 'https://readarr.com';
      case ZagModule.BAZARR:
        return 'https://bazarr.media';
    }
  }

  String? get github {
    switch (this) {
      case ZagModule.DASHBOARD:
        return null;
      case ZagModule.LIDARR:
        return 'https://github.com/Lidarr/Lidarr';
      case ZagModule.NZBGET:
        return 'https://github.com/nzbget/nzbget';
      case ZagModule.RADARR:
        return 'https://github.com/Radarr/Radarr';
      case ZagModule.SABNZBD:
        return 'https://github.com/sabnzbd/sabnzbd';
      case ZagModule.SEARCH:
        return 'https://github.com/theotherp/nzbhydra2';
      case ZagModule.SETTINGS:
        return null;
      case ZagModule.SONARR:
        return 'https://github.com/Sonarr/Sonarr';
      case ZagModule.TAUTULLI:
        return 'https://github.com/Tautulli/Tautulli';
      case ZagModule.OVERSEERR:
        return 'https://github.com/sct/overseerr';
      case ZagModule.WAKE_ON_LAN:
        return null;
      case ZagModule.EXTERNAL_MODULES:
        return null;
      case ZagModule.DISCOVER:
        return null;
      case ZagModule.UNRAID:
        return null;
      case ZagModule.READARR:
        return 'https://github.com/Readarr/Readarr';
      case ZagModule.BAZARR:
        return 'https://github.com/morpheus65535/bazarr';
    }
  }

  String get description {
    switch (this) {
      case ZagModule.DASHBOARD:
        return 'Manage modules and your calendar';
      case ZagModule.LIDARR:
        return 'Manage Music';
      case ZagModule.NZBGET:
        return 'Manage Usenet Downloads';
      case ZagModule.RADARR:
        return 'Manage Movies';
      case ZagModule.SABNZBD:
        return 'Manage Usenet Downloads';
      case ZagModule.SEARCH:
        return 'Search Newznab Indexers';
      case ZagModule.SETTINGS:
        return 'Configure Zagreus';
      case ZagModule.SONARR:
        return 'Manage Television Series';
      case ZagModule.TAUTULLI:
        return 'View Plex Activity';
      case ZagModule.OVERSEERR:
        return 'Manage Requests for New Content';
      case ZagModule.WAKE_ON_LAN:
        return 'Wake Your Machine';
      case ZagModule.EXTERNAL_MODULES:
        return 'Access External Modules';
      case ZagModule.DISCOVER:
        return 'Browse movies, shows, and calendar views';
      case ZagModule.UNRAID:
        return 'Manage Your Unraid Server';
      case ZagModule.READARR:
        return 'Manage Books and Audiobooks';
      case ZagModule.BAZARR:
        return 'Manage Subtitles';
    }
  }

  String? get information {
    switch (this) {
      case ZagModule.DASHBOARD:
        return 'Quickly launch modules, wake devices, and review upcoming events.';
      case ZagModule.LIDARR:
        return 'Lidarr is a music collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new tracks from your favorite artists and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.';
      case ZagModule.NZBGET:
        return 'NZBGet is a binary downloader, which downloads files from Usenet based on information given in nzb-files.';
      case ZagModule.RADARR:
        return 'Radarr is a movie collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new movies and will interface with clients and indexers to grab, sort, and rename them. It can also be configured to automatically upgrade the quality of existing files in the library when a better quality format becomes available.';
      case ZagModule.SABNZBD:
        return 'SABnzbd is a multi-platform binary newsgroup downloader. The program works in the background and simplifies the downloading verifying and extracting of files from Usenet.';
      case ZagModule.SEARCH:
        return 'Zagreus currently supports all indexers that support the newznab protocol, including NZBHydra2.';
      case ZagModule.SETTINGS:
        return null;
      case ZagModule.SONARR:
        return 'Sonarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.';
      case ZagModule.TAUTULLI:
        return 'Tautulli is an application that you can run alongside your Plex Media Server to monitor activity and track various statistics. Most importantly, these statistics include what has been watched, who watched it, when and where they watched it, and how it was watched.';
      case ZagModule.OVERSEERR:
        return 'Overseerr is a free and open source software application for managing requests for your media library. It integrates with your existing services, such as Sonarr, Radarr, and Plex!';
      case ZagModule.WAKE_ON_LAN:
        return 'Wake on LAN is an industry standard protocol for waking computers up from a very low power mode remotely by sending a specially constructed packet to the machine.';
      case ZagModule.EXTERNAL_MODULES:
        return 'Zagreus allows you to add links to additional modules that are not currently supported allowing you to open the module\'s web GUI without having to leave Zagreus!';
      case ZagModule.DISCOVER:
        return 'Discover new movies and TV shows, browse what\'s trending, see what\'s coming soon, and explore your recently downloaded content.';
      case ZagModule.UNRAID:
        return 'Monitor and manage your Unraid server, including system information, array status, Docker containers, and virtual machines.';
      case ZagModule.READARR:
        return 'Readarr is an ebook and audiobook collection manager for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new books from your favorite authors and will grab, sort, and organize them. It can also be configured to automatically upgrade the quality of existing files in your library when a better quality format becomes available.';
      case ZagModule.BAZARR:
        return 'Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles based on your requirements. You can define your preferred languages in profiles and Bazarr takes care of everything for you.';
    }
  }
}

extension ZagModuleRoutingExtension on ZagModule {
  String? get homeRoute {
    switch (this) {
      case ZagModule.DASHBOARD:
        return ZagRoutes.dashboard.root.path;
      case ZagModule.LIDARR:
        return ZagRoutes.lidarr.root.path;
      case ZagModule.NZBGET:
        return ZagRoutes.nzbget.root.path;
      case ZagModule.RADARR:
        return ZagRoutes.radarr.root.path;
      case ZagModule.SABNZBD:
        return ZagRoutes.sabnzbd.root.path;
      case ZagModule.SEARCH:
        return ZagRoutes.search.root.path;
      case ZagModule.SETTINGS:
        return ZagRoutes.settings.root.path;
      case ZagModule.SONARR:
        return ZagRoutes.sonarr.root.path;
      case ZagModule.TAUTULLI:
        return ZagRoutes.tautulli.root.path;
      case ZagModule.OVERSEERR:
        return ZagRoutes.overseerr.root.path;
      case ZagModule.WAKE_ON_LAN:
        return null;
      case ZagModule.EXTERNAL_MODULES:
        return ZagRoutes.externalModules.root.path;
      case ZagModule.DISCOVER:
        return ZagRoutes.discover.root.path;
      case ZagModule.UNRAID:
        return ZagRoutes.unraid.root.path;
      case ZagModule.READARR:
        return ZagRoutes.readarr.root.path;
      case ZagModule.BAZARR:
        return null; // Bazarr is integrated into Radarr/Sonarr
    }
  }

  SettingsRoutes? get settingsRoute {
    switch (this) {
      case ZagModule.DASHBOARD:
        return SettingsRoutes.CONFIGURATION_DASHBOARD;
      case ZagModule.LIDARR:
        return SettingsRoutes.CONFIGURATION_LIDARR;
      case ZagModule.NZBGET:
        return SettingsRoutes.CONFIGURATION_NZBGET;
      case ZagModule.OVERSEERR:
        return SettingsRoutes.CONFIGURATION_OVERSEERR;
      case ZagModule.RADARR:
        return SettingsRoutes.CONFIGURATION_RADARR;
      case ZagModule.SABNZBD:
        return SettingsRoutes.CONFIGURATION_SABNZBD;
      case ZagModule.SEARCH:
        return SettingsRoutes.CONFIGURATION_SEARCH;
      case ZagModule.SETTINGS:
        return null;
      case ZagModule.SONARR:
        return SettingsRoutes.CONFIGURATION_SONARR;
      case ZagModule.TAUTULLI:
        return SettingsRoutes.CONFIGURATION_TAUTULLI;
      case ZagModule.WAKE_ON_LAN:
        return SettingsRoutes.CONFIGURATION_WAKE_ON_LAN;
      case ZagModule.EXTERNAL_MODULES:
        return SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES;
      case ZagModule.DISCOVER:
        return SettingsRoutes.CONFIGURATION_DASHBOARD_SECTIONS;
      case ZagModule.UNRAID:
        return SettingsRoutes.CONFIGURATION_UNRAID;
      case ZagModule.READARR:
        return SettingsRoutes.CONFIGURATION_READARR;
      case ZagModule.BAZARR:
        return SettingsRoutes.CONFIGURATION_BAZARR;
    }
  }

  Future<void> launch({bool restore = true}) async {
    final home = homeRoute;
    if (home == null) return;

    final savedRoute = restore ? ZagSessionState.instance.getModuleLastRoute(key) : null;
    final shouldRestore =
        savedRoute != null && canRestoreRoute(savedRoute);
    final String targetRoute = shouldRestore ? savedRoute : home;

    ZagLogger().debug(
      '🔍 Module.launch: restore=$restore, Restoring route => $shouldRestore ($targetRoute)',
    );
    ZagRouter.router.pushReplacement(targetRoute);
  }

  bool canRestoreRoute(String route) {
    final home = homeRoute;
    if (home == null) return false;
    if (!route.startsWith(home)) return false;

    final path = Uri.tryParse(route)?.path ?? route;
    switch (this) {
      case ZagModule.RADARR:
        return !_hasPrefix(path, _radarrNonRestorablePrefixes);
      case ZagModule.SONARR:
        return !_hasPrefix(path, _sonarrNonRestorablePrefixes);
      case ZagModule.LIDARR:
        return !_hasPrefix(path, _lidarrNonRestorablePrefixes);
      default:
        return true;
    }
  }

  bool _hasPrefix(String route, List<String> disallowedPrefixes) {
    for (final prefix in disallowedPrefixes) {
      if (route.startsWith(prefix)) return true;
    }
    return false;
  }
}

const List<String> _radarrNonRestorablePrefixes = <String>[
  '/radarr/add_movie/details',
  '/radarr/manual_import/details',
];

const List<String> _sonarrNonRestorablePrefixes = <String>[
  '/sonarr/add_series/details',
];

const List<String> _lidarrNonRestorablePrefixes = <String>[
  '/lidarr/add_artist/details',
];

extension ZagModuleWebhookExtension on ZagModule {
  bool get hasWebhooks {
    switch (this) {
      case ZagModule.LIDARR:
        return true;
      case ZagModule.RADARR:
        return true;
      case ZagModule.SONARR:
        return true;
      case ZagModule.OVERSEERR:
        return true;
      case ZagModule.TAUTULLI:
        return true;
      default:
        return false;
    }
  }

  String? get webhookDocs {
    switch (this) {
      case ZagModule.LIDARR:
        return 'https://docs.zagreus.app/zagreus/notifications/lidarr';
      case ZagModule.RADARR:
        return 'https://docs.zagreus.app/zagreus/notifications/radarr';
      case ZagModule.SONARR:
        return 'https://docs.zagreus.app/zagreus/notifications/sonarr';
      case ZagModule.OVERSEERR:
        return 'https://docs.zagreus.app/zagreus/notifications/overseerr';
      case ZagModule.TAUTULLI:
        return 'https://docs.zagreus.app/zagreus/notifications/tautulli';
      default:
        return null;
    }
  }

  Future<void> handleWebhook(Map<String, dynamic> data) async {
    switch (this) {
      case ZagModule.LIDARR:
        return LidarrWebhooks().handle(data);
      case ZagModule.RADARR:
        return RadarrWebhooks().handle(data);
      case ZagModule.SONARR:
        return SonarrWebhooks().handle(data);
      case ZagModule.TAUTULLI:
        return TautulliWebhooks().handle(data);
      default:
        return;
    }
  }
}

extension ZagModuleExtension on ZagModule {
  ShortcutItem get shortcutItem {
    if (this == ZagModule.WAKE_ON_LAN || this == ZagModule.DISCOVER) {
      throw Exception('$this does not have a shortcut item');
    }
    return ShortcutItem(type: key, localizedTitle: title);
  }

  ZagModuleState? state(BuildContext context) {
    switch (this) {
      case ZagModule.WAKE_ON_LAN:
        return null;
      case ZagModule.DASHBOARD:
        return context.read<DashboardState>();
      case ZagModule.SETTINGS:
        return context.read<SettingsState>();
      case ZagModule.SEARCH:
        return context.read<SearchState>();
      case ZagModule.LIDARR:
        return context.read<LidarrState>();
      case ZagModule.RADARR:
        return context.read<RadarrState>();
      case ZagModule.SONARR:
        return context.read<SonarrState>();
      case ZagModule.NZBGET:
        return context.read<NZBGetState>();
      case ZagModule.SABNZBD:
        return context.read<SABnzbdState>();
      case ZagModule.OVERSEERR:
        return context.read<OverseerrState>();
      case ZagModule.TAUTULLI:
        return context.read<TautulliState>();
      case ZagModule.EXTERNAL_MODULES:
        return null;
      case ZagModule.DISCOVER:
        return null;
      case ZagModule.UNRAID:
        return context.read<UnraidState>();
      case ZagModule.READARR:
        return context.read<ReadarrState>();
      case ZagModule.BAZARR:
        return null; // Bazarr doesn't have its own state - integrated into Radarr/Sonarr
    }
  }

  Widget informationBanner() {
    String key = 'ZAGREUS_MODULE_INFORMATION_${this.key}';
    void markSeen() => ZagBox.alerts.update(key, false);

    return ZagBox.alerts.listenableBuilder(
      selectKeys: [key],
      builder: (context, _) {
        if (ZagBox.alerts.read(key, fallback: true)) {
          return ZagBanner(
            dismissCallback: markSeen,
            headerText: this.title,
            bodyText: this.information,
            icon: this.icon,
            iconColor: this.color,
            buttons: [
              if (this.github != null)
                ZagButton.text(
                  text: 'GitHub',
                  icon: ZagIcons.GITHUB,
                  onTap: this.github!.openLink,
                ),
              if (this.website != null)
                ZagButton.text(
                  text: 'zagreus.Website'.tr(),
                  icon: Icons.home_rounded,
                  onTap: this.website!.openLink,
                ),
            ],
          );
        }
        return const SizedBox(height: 0.0, width: double.infinity);
      },
    );
  }
}
