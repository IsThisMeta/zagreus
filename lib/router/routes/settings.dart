import 'package:flutter/material.dart';

import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/settings/routes/account/route.dart';
import 'package:zagreus/modules/settings/routes/account/pages/password_reset.dart';
import 'package:zagreus/modules/settings/routes/account/pages/settings.dart';
import 'package:zagreus/modules/settings/routes/configuration_general/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_appearance/route.dart';
import 'package:zagreus/modules/settings/routes/configuration/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_dashboard/pages/calendar_settings.dart';
import 'package:zagreus/modules/settings/routes/configuration_dashboard/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_dashboard/route.dart';
import 'package:zagreus/modules/settings/routes/discover_sections/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_drawer/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_navigation/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_external_modules/pages/add_module.dart';
import 'package:zagreus/modules/settings/routes/configuration_external_modules/pages/edit_module.dart';
import 'package:zagreus/modules/settings/routes/configuration_external_modules/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_lidarr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_lidarr/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_lidarr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_lidarr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_nzbget/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_nzbget/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_nzbget/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_nzbget/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_overseerr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_overseerr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_overseerr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_quick_actions/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_radarr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_radarr/pages/default_options.dart';
import 'package:zagreus/modules/settings/routes/configuration_radarr/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_radarr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_radarr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_readarr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_readarr/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_readarr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_readarr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_sabnzbd/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_sabnzbd/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_sabnzbd/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_sabnzbd/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/pages/add_indexer.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/pages/add_indexer_headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/pages/add_prowlarr.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/pages/edit_indexer.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/pages/edit_indexer_headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_search/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_sonarr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_sonarr/pages/default_options.dart';
import 'package:zagreus/modules/settings/routes/configuration_sonarr/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_sonarr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_sonarr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_tautulli/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_tautulli/pages/default_pages.dart';
import 'package:zagreus/modules/settings/routes/configuration_tautulli/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_tautulli/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_unraid/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_unraid/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_bazarr/route.dart';
import 'package:zagreus/modules/settings/routes/configuration_bazarr/pages/connection_details.dart';
import 'package:zagreus/modules/settings/routes/configuration_bazarr/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_ssh/route.dart';
import 'package:zagreus/modules/ssh/routes/ssh/pages/add_connection.dart';
import 'package:zagreus/modules/ssh/routes/ssh/pages/edit_connection.dart';
import 'package:zagreus/modules/settings/core/pages/headers.dart';
import 'package:zagreus/modules/settings/routes/configuration_wake_on_lan/route.dart';
import 'package:zagreus/modules/settings/routes/z_agent/route.dart';
import 'package:zagreus/modules/settings/routes/notifications/route.dart';
import 'package:zagreus/modules/settings/routes/profiles/route.dart';
import 'package:zagreus/modules/settings/routes/resources/route.dart';
import 'package:zagreus/modules/settings/routes/settings/route.dart';
import 'package:zagreus/modules/settings/routes/subscriptions/route.dart';
import 'package:zagreus/modules/settings/routes/system/route.dart';
import 'package:zagreus/modules/settings/routes/system_logs/pages/log_details.dart';
import 'package:zagreus/modules/settings/routes/system_logs/route.dart';
import 'package:zagreus/router/routes.dart';
import 'package:zagreus/types/log_type.dart';
import 'package:zagreus/vendor.dart';

enum SettingsRoutes with ZagRoutesMixin {
  HOME('/settings'),
  ACCOUNT('account'),
  ACCOUNT_PASSWORD_RESET('password_reset'),
  ACCOUNT_SETTINGS('settings'),
  CONFIGURATION('configuration'),
  CONFIGURATION_GENERAL('general'),
  CONFIGURATION_APPEARANCE('appearance'),
  CONFIGURATION_DASHBOARD('dashboard'),
  CONFIGURATION_DASHBOARD_SECTIONS('dashboard_sections'),
  CONFIGURATION_DASHBOARD_CALENDAR('calendar'),
  CONFIGURATION_DASHBOARD_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_DRAWER('drawer'),
  CONFIGURATION_NAVIGATION('navigation'),
  CONFIGURATION_EXTERNAL_MODULES('external_modules'),
  CONFIGURATION_EXTERNAL_MODULES_ADD('add'),
  CONFIGURATION_EXTERNAL_MODULES_EDIT('edit/:id'),
  CONFIGURATION_LIDARR('lidarr'),
  CONFIGURATION_LIDARR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_LIDARR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_LIDARR_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_NZBGET('nzbget'),
  CONFIGURATION_NZBGET_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_NZBGET_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_NZBGET_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_OVERSEERR('overseerr'),
  CONFIGURATION_OVERSEERR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_OVERSEERR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_QUICK_ACTIONS('quick_actions'),
  CONFIGURATION_RADARR('radarr'),
  CONFIGURATION_RADARR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_RADARR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_RADARR_DEFAULT_OPTIONS('default_options'),
  CONFIGURATION_RADARR_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_READARR('readarr'),
  CONFIGURATION_READARR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_READARR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_READARR_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_SABNZBD('sabnzbd'),
  CONFIGURATION_SABNZBD_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_SABNZBD_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_SABNZBD_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_SEARCH('search'),
  CONFIGURATION_SEARCH_ADD_PROWLARR('add_prowlarr'),
  CONFIGURATION_SEARCH_ADD_INDEXER('add_indexer'),
  CONFIGURATION_SEARCH_ADD_INDEXER_HEADERS('headers'),
  CONFIGURATION_SEARCH_ADD_PROWLARR_HEADERS('headers'),
  CONFIGURATION_SEARCH_EDIT_INDEXER('edit_indexer/:id'),
  CONFIGURATION_SEARCH_EDIT_INDEXER_HEADERS('headers'),
  CONFIGURATION_SONARR('sonarr'),
  CONFIGURATION_SONARR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_SONARR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_SONARR_DEFAULT_OPTIONS('default_options'),
  CONFIGURATION_SONARR_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_TAUTULLI('tautulli'),
  CONFIGURATION_TAUTULLI_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_TAUTULLI_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_TAUTULLI_DEFAULT_PAGES('default_pages'),
  CONFIGURATION_UNRAID('server'),
  CONFIGURATION_UNRAID_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_UNRAID_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_WAKE_ON_LAN('wake_on_lan'),
  CONFIGURATION_BAZARR('bazarr'),
  CONFIGURATION_BAZARR_CONNECTION_DETAILS('connection_details'),
  CONFIGURATION_BAZARR_CONNECTION_DETAILS_HEADERS('headers'),
  CONFIGURATION_SSH('ssh'),
  CONFIGURATION_SSH_ADD_CONNECTION('add'),
  CONFIGURATION_SSH_EDIT_CONNECTION('edit/:connectionId'),
  Z_AGENT('z_agent'),
  NOTIFICATIONS('notifications'),
  PROFILES('profiles'),
  RESOURCES('resources'),
  SUBSCRIPTIONS('subscriptions'),
  SYSTEM('system'),
  SYSTEM_LOGS('logs'),
  SYSTEM_LOGS_DETAILS('view/:type');

  @override
  final String path;

  const SettingsRoutes(this.path);

  @override
  ZagModule get module => ZagModule.SETTINGS;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case SettingsRoutes.HOME:
        return route(widget: const SettingsRoute());
      case SettingsRoutes.ACCOUNT:
        return route(widget: const AccountRoute());
      case SettingsRoutes.ACCOUNT_PASSWORD_RESET:
        return route(widget: const AccountPasswordResetRoute());
      case SettingsRoutes.ACCOUNT_SETTINGS:
        return route(widget: const AccountSettingsRoute());
      case SettingsRoutes.CONFIGURATION:
        return route(widget: const ConfigurationRoute());
      case SettingsRoutes.CONFIGURATION_GENERAL:
        return route(widget: const ConfigurationGeneralRoute());
      case SettingsRoutes.CONFIGURATION_APPEARANCE:
        return route(widget: const ConfigurationAppearanceRoute());
      case SettingsRoutes.CONFIGURATION_DASHBOARD:
        return route(widget: const ConfigurationDashboardRoute());
      case SettingsRoutes.CONFIGURATION_DASHBOARD_SECTIONS:
        return route(widget: const DashboardSectionsRoute());
      case SettingsRoutes.CONFIGURATION_DASHBOARD_CALENDAR:
        return route(widget: const ConfigurationDashboardCalendarRoute());
      case SettingsRoutes.CONFIGURATION_DASHBOARD_DEFAULT_PAGES:
        return route(widget: const ConfigurationDashboardDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_DRAWER:
        return route(widget: const ConfigurationDrawerRoute());
      case SettingsRoutes.CONFIGURATION_NAVIGATION:
        return route(widget: const ConfigurationNavigationRoute());
      case SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES:
        return route(widget: const ConfigurationExternalModulesRoute());
      case SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_ADD:
        return route(widget: const ConfigurationExternalModulesAddRoute());
      case SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_EDIT:
        return route(builder: (_, state) {
          final moduleId = int.tryParse(state.pathParameters['id']!) ?? -1;
          return ConfigurationExternalModulesEditRoute(moduleId: moduleId);
        });
      case SettingsRoutes.CONFIGURATION_LIDARR:
        return route(widget: const ConfigurationLidarrRoute());
      case SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS:
        return route(widget: const ConfigurationLidarrConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationLidarrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_LIDARR_DEFAULT_PAGES:
        return route(widget: const ConfigurationLidarrDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_NZBGET:
        return route(widget: const ConfigurationNZBGetRoute());
      case SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS:
        return route(widget: const ConfigurationNZBGetConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationNZBGetConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_NZBGET_DEFAULT_PAGES:
        return route(widget: const ConfigurationNZBGetDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_OVERSEERR:
        return route(widget: const ConfigurationOverseerrRoute());
      case SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS:
        return route(widget: const ConfigurationOverseerrConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationOverseerrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_QUICK_ACTIONS:
        return route(widget: const ConfigurationQuickActionsRoute());
      case SettingsRoutes.CONFIGURATION_RADARR:
        return route(widget: const ConfigurationRadarrRoute());
      case SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS:
        return route(widget: const ConfigurationRadarrConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationRadarrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_OPTIONS:
        return route(widget: const ConfigurationRadarrDefaultOptionsRoute());
      case SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_PAGES:
        return route(widget: const ConfigurationRadarrDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_READARR:
        return route(widget: const ConfigurationReadarrRoute());
      case SettingsRoutes.CONFIGURATION_READARR_CONNECTION_DETAILS:
        return route(
          widget: const ConfigurationReadarrConnectionDetailsRoute(),
        );
      case SettingsRoutes.CONFIGURATION_READARR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationReadarrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_READARR_DEFAULT_PAGES:
        return route(widget: const ConfigurationReadarrDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_SABNZBD:
        return route(widget: const ConfigurationSABnzbdRoute());
      case SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS:
        return route(
          widget: const ConfigurationSABnzbdConnectionDetailsRoute(),
        );
      case SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationSABnzbdConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_SABNZBD_DEFAULT_PAGES:
        return route(widget: const ConfigurationSABnzbdDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_SEARCH:
        return route(widget: const ConfigurationSearchRoute());
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR:
        return route(widget: const ConfigurationSearchAddProwlarrRoute());
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER:
        return route(widget: const ConfigurationSearchAddIndexerRoute());
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER_HEADERS:
        return route(builder: (_, state) {
          final indexer = state.extra as ZagIndexer?;
          return ConfigurationSearchAddIndexerHeadersRoute(indexer: indexer);
        });
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR_HEADERS:
        return route(
          builder: (_, state) => const ConfigurationSearchAddIndexerHeadersRoute(
            indexer: null,
          ),
        );
      case SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER:
        return route(builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id']!) ?? -1;
          return ConfigurationSearchEditIndexerRoute(id: id);
        });
      case SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER_HEADERS:
        return route(builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id']!) ?? -1;
          return ConfigurationSearchEditIndexerHeadersRoute(id: id);
        });
      case SettingsRoutes.CONFIGURATION_SONARR:
        return route(widget: const ConfigurationSonarrRoute());
      case SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS:
        return route(widget: const ConfigurationSonarrConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationSonarrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_OPTIONS:
        return route(widget: const ConfigurationSonarrDefaultOptionsRoute());
      case SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_PAGES:
        return route(widget: const ConfigurationSonarrDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_TAUTULLI:
        return route(widget: const ConfigurationTautulliRoute());
      case SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS:
        return route(
          widget: const ConfigurationTautulliConnectionDetailsRoute(),
        );
      case SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationTautulliConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_TAUTULLI_DEFAULT_PAGES:
        return route(widget: const ConfigurationTautulliDefaultPagesRoute());
      case SettingsRoutes.CONFIGURATION_UNRAID:
        return route(widget: const ConfigurationUnraidRoute());
      case SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS:
        return route(widget: const ConfigurationUnraidConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS_HEADERS:
        return route(widget: SettingsHeaderRoute(module: ZagModule.UNRAID));
      case SettingsRoutes.CONFIGURATION_WAKE_ON_LAN:
        return route(widget: const ConfigurationWakeOnLANRoute());
      case SettingsRoutes.CONFIGURATION_BAZARR:
        return route(widget: const ConfigurationBazarrRoute());
      case SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS:
        return route(widget: const ConfigurationBazarrConnectionDetailsRoute());
      case SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS_HEADERS:
        return route(
          widget: const ConfigurationBazarrConnectionDetailsHeadersRoute(),
        );
      case SettingsRoutes.CONFIGURATION_SSH:
        return route(widget: const ConfigurationSSHRoute());
      case SettingsRoutes.CONFIGURATION_SSH_ADD_CONNECTION:
        return route(widget: const SSHAddConnectionRoute());
      case SettingsRoutes.CONFIGURATION_SSH_EDIT_CONNECTION:
        return route(builder: (_, state) {
          final connectionId = state.pathParameters['connectionId'] ?? '';
          return SSHEditConnectionRoute(connectionId: connectionId);
        });
      case SettingsRoutes.Z_AGENT:
        return route(widget: const ZAgentSettingsRoute());
      case SettingsRoutes.NOTIFICATIONS:
        return route(widget: const NotificationsRoute());
      case SettingsRoutes.PROFILES:
        return route(widget: const ProfilesRoute());
      case SettingsRoutes.RESOURCES:
        return route(widget: const SettingsResourcesRoute());
      case SettingsRoutes.SUBSCRIPTIONS:
        return route(widget: const SubscriptionsRoute());
      case SettingsRoutes.SYSTEM:
        return route(widget: const SystemRoute());
      case SettingsRoutes.SYSTEM_LOGS:
        return route(widget: const SystemLogsRoute());
      case SettingsRoutes.SYSTEM_LOGS_DETAILS:
        return route(builder: (_, state) {
          final type = ZagLogType.fromKey(state.pathParameters['type']!);
          return SystemLogsDetailsRoute(type: type);
        });
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case SettingsRoutes.HOME:
        return [
          SettingsRoutes.ACCOUNT.routes,
          SettingsRoutes.CONFIGURATION.routes,
          SettingsRoutes.NOTIFICATIONS.routes,
          SettingsRoutes.PROFILES.routes,
          SettingsRoutes.RESOURCES.routes,
          SettingsRoutes.SUBSCRIPTIONS.routes,
          SettingsRoutes.SYSTEM.routes,
        ];
      case SettingsRoutes.ACCOUNT:
        return [
          SettingsRoutes.ACCOUNT_PASSWORD_RESET.routes,
          SettingsRoutes.ACCOUNT_SETTINGS.routes,
        ];
      case SettingsRoutes.CONFIGURATION:
        return [
          SettingsRoutes.CONFIGURATION_GENERAL.routes,
          SettingsRoutes.CONFIGURATION_APPEARANCE.routes,
          SettingsRoutes.CONFIGURATION_DASHBOARD.routes,
          SettingsRoutes.CONFIGURATION_DASHBOARD_SECTIONS.routes,
          SettingsRoutes.CONFIGURATION_DRAWER.routes,
          SettingsRoutes.CONFIGURATION_NAVIGATION.routes,
          SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES.routes,
          SettingsRoutes.CONFIGURATION_LIDARR.routes,
          SettingsRoutes.CONFIGURATION_NZBGET.routes,
          SettingsRoutes.CONFIGURATION_OVERSEERR.routes,
          SettingsRoutes.CONFIGURATION_QUICK_ACTIONS.routes,
          SettingsRoutes.CONFIGURATION_RADARR.routes,
          SettingsRoutes.CONFIGURATION_READARR.routes,
          SettingsRoutes.CONFIGURATION_SABNZBD.routes,
          SettingsRoutes.CONFIGURATION_SEARCH.routes,
          SettingsRoutes.CONFIGURATION_SONARR.routes,
          SettingsRoutes.CONFIGURATION_TAUTULLI.routes,
          SettingsRoutes.CONFIGURATION_UNRAID.routes,
          SettingsRoutes.CONFIGURATION_WAKE_ON_LAN.routes,
          SettingsRoutes.CONFIGURATION_BAZARR.routes,
          SettingsRoutes.CONFIGURATION_SSH.routes,
          SettingsRoutes.Z_AGENT.routes,
        ];
      case SettingsRoutes.CONFIGURATION_DASHBOARD:
        return [
          SettingsRoutes.CONFIGURATION_DASHBOARD_CALENDAR.routes,
          SettingsRoutes.CONFIGURATION_DASHBOARD_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_LIDARR:
        return [
          SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_LIDARR_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_NZBGET:
        return [
          SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_NZBGET_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_OVERSEERR:
        return [
          SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_OVERSEERR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_RADARR:
        return [
          SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_OPTIONS.routes,
          SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_READARR:
        return [
          SettingsRoutes.CONFIGURATION_READARR_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_READARR_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_READARR_CONNECTION_DETAILS:
        return [
          SettingsRoutes
              .CONFIGURATION_READARR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SABNZBD:
        return [
          SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_SABNZBD_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS:
        return [
          SettingsRoutes
              .CONFIGURATION_SABNZBD_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SEARCH:
        return [
          SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR.routes,
          SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER.routes,
          SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR:
        return [
          SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER:
        return [
          SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER:
        return [
          SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SONARR:
        return [
          SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_OPTIONS.routes,
          SettingsRoutes.CONFIGURATION_SONARR_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_TAUTULLI:
        return [
          SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS.routes,
          SettingsRoutes.CONFIGURATION_TAUTULLI_DEFAULT_PAGES.routes,
        ];
      case SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS:
        return [
          SettingsRoutes
              .CONFIGURATION_TAUTULLI_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_UNRAID:
        return [
          SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_UNRAID_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_BAZARR:
        return [
          SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS:
        return [
          SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS_HEADERS.routes,
        ];
      case SettingsRoutes.CONFIGURATION_SSH:
        return [
          SettingsRoutes.CONFIGURATION_SSH_ADD_CONNECTION.routes,
          SettingsRoutes.CONFIGURATION_SSH_EDIT_CONNECTION.routes,
        ];
      case SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES:
        return [
          SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_ADD.routes,
          SettingsRoutes.CONFIGURATION_EXTERNAL_MODULES_EDIT.routes,
        ];
      case SettingsRoutes.SYSTEM:
        return [
          SettingsRoutes.SYSTEM_LOGS.routes,
        ];
      case SettingsRoutes.SYSTEM_LOGS:
        return [
          SettingsRoutes.SYSTEM_LOGS_DETAILS.routes,
        ];
      default:
        return const <GoRoute>[];
    }
  }
}
