import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/backup_tile.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/build_details.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/restore_tile.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/demo_config.dart';
import 'package:zagreus/system/cache/image/image_cache.dart';

class SystemRoute extends StatefulWidget {
  const SystemRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SystemRoute> createState() => _State();
}

class _State extends State<SystemRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'settings.System'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: <Widget>[
        const BuildDetails(),
        ZagDivider(),
        const SettingsSystemBackupRestoreBackupTile(),
        const SettingsSystemBackupRestoreRestoreTile(),
        ZagDivider(),
        _logs(),
        _clearImageCache(),
        _clearConfiguration(),
        ZagDivider(),
        _buildDemoButton(),
      ],
    );
  }

  Widget _logs() {
    return ZagBlock(
      title: 'settings.Logs'.tr(),
      body: [TextSpan(text: 'settings.LogsDescription'.tr())],
      trailing: const ZagIconButton(icon: Icons.developer_mode_rounded),
      onTap: SettingsRoutes.SYSTEM_LOGS.go,
    );
  }

  Widget _clearImageCache() {
    return ZagBlock(
      title: 'settings.ClearImageCache'.tr(),
      body: [TextSpan(text: 'settings.ClearImageCacheDescription'.tr())],
      trailing: const ZagIconButton(icon: Icons.image_not_supported_rounded),
      onTap: () async {
        bool result = await SettingsDialogs().clearImageCache(context);
        if (result) {
          result = await ZagImageCache().clear();
          if (result) {
            showZagSuccessSnackBar(
              title: 'settings.ImageCacheCleared'.tr(),
              message: 'settings.ImageCacheClearedDescription'.tr(),
            );
          } else {
            showZagErrorSnackBar(
              title: 'settings.FailedToClearImageCache'.tr(),
              message: 'settings.FailedToClearImageCacheDescription'.tr(),
            );
          }
        }
      },
    );
  }

  Widget _clearConfiguration() {
    return ZagBlock(
      title: 'settings.ClearConfiguration'.tr(),
      body: [TextSpan(text: 'settings.CleanSlate'.tr())],
      trailing: const ZagIconButton(icon: Icons.delete_sweep_rounded),
      onTap: () async {
        bool result = await SettingsDialogs().clearConfiguration(context);
        if (result) {
          ZagDatabase().bootstrap();
          ZagState.reset(context);
          showZagSuccessSnackBar(
            title: 'settings.ConfigurationCleared'.tr(),
            message: 'settings.ConfigurationClearedDescription'.tr(),
          );
        }
      },
    );
  }

  Widget _buildDemoButton() {
    return ZagBlock(
      title: 'Review Demo',
      body: [],
      trailing: ZagIconButton(
        icon: Icons.play_circle_outline_rounded,
        color: ZagColours.orange,
      ),
      onTap: () => _loadDemoConfiguration(context),
    );
  }

  Future<void> _loadDemoConfiguration(BuildContext context) async {
    // Show password dialog
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review Access'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter review password',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ZagColours.currentAccent),
            ),
            labelStyle: TextStyle(color: ZagColours.currentAccent),
          ),
          autofocus: true,
          cursorColor: ZagColours.currentAccent,
          onSubmitted: (_) => Navigator.of(context).pop(passwordController.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: Text(
              'Continue',
              style: TextStyle(color: ZagColours.currentAccentLight),
            ),
          ),
        ],
      ),
    );

    // Check password
    if (password != 'review2025') {
      if (password != null) {
        showZagErrorSnackBar(
          title: 'Access Denied',
          message: 'Invalid password',
        );
      }
      return;
    }

    showZagInfoSnackBar(
      title: 'Loading Demo Configuration',
      message: 'Checking demo availability...',
    );

    // Check Supabase for demo config
    final demoConfig = await ZagDemoConfig.fetchDemoConfig();

    if (demoConfig == null || demoConfig['enabled'] != true) {
      showZagErrorSnackBar(
        title: 'Demo Unavailable',
        message: 'Demo configuration is not available at this time',
      );
      return;
    }

    // Build profile from Supabase data or use defaults
    final profile = ZagProfile(
      // Lidarr
      lidarrEnabled: demoConfig['lidarr_enabled'] ?? false,
      lidarrHost: demoConfig['lidarr_host'] ?? '',
      lidarrKey: demoConfig['lidarr_key'] ?? '',
      lidarrHeaders: {},

      // NZBGet
      nzbgetEnabled: demoConfig['nzbget_enabled'] ?? false,
      nzbgetHost: demoConfig['nzbget_host'] ?? '',
      nzbgetUser: demoConfig['nzbget_user'] ?? '',
      nzbgetPass: demoConfig['nzbget_pass'] ?? '',
      nzbgetHeaders: {},

      // Radarr
      radarrEnabled: demoConfig['radarr_enabled'] ?? false,
      radarrHost: demoConfig['radarr_host'] ?? '',
      radarrKey: demoConfig['radarr_key'] ?? '',
      radarrHeaders: {},

      // SABnzbd
      sabnzbdEnabled: demoConfig['sabnzbd_enabled'] ?? false,
      sabnzbdHost: demoConfig['sabnzbd_host'] ?? '',
      sabnzbdKey: demoConfig['sabnzbd_key'] ?? '',
      sabnzbdHeaders: {},

      // Sonarr
      sonarrEnabled: demoConfig['sonarr_enabled'] ?? false,
      sonarrHost: demoConfig['sonarr_host'] ?? '',
      sonarrKey: demoConfig['sonarr_key'] ?? '',
      sonarrHeaders: {},

      // Tautulli
      tautulliEnabled: demoConfig['tautulli_enabled'] ?? false,
      tautulliHost: demoConfig['tautulli_host'] ?? '',
      tautulliKey: demoConfig['tautulli_key'] ?? '',
      tautulliHeaders: {},

      // Overseerr
      overseerrEnabled: false,
      overseerrHost: '',
      overseerrKey: '',
      overseerrHeaders: {},
      // Server
      serverEnabled: demoConfig['server_enabled'] ?? true,
      serverHost:
          demoConfig['server_host'] ?? 'http://192.168.0.48:7878',
      serverKey: demoConfig['server_key'] ??
          '4f881bebb9da6a41431cfa5b194b36fa12094a87b5164886542ddfa2e235066c',
      serverHeaders: const <String, String>{},
    );

    // Save the profile with Radarr and Sonarr initially disabled (workaround)
    profile.radarrEnabled = false;
    profile.sonarrEnabled = false;
    await ZagBox.profiles.update(ZagProfile.DEFAULT_PROFILE, profile);

    // Now re-enable Radarr and Sonarr to fix the bug
    profile.radarrEnabled = true;
    profile.sonarrEnabled = true;
    await ZagBox.profiles.update(ZagProfile.DEFAULT_PROFILE, profile);

    // Set the drawer order (excluding Dashboard since it's always added automatically)
    // First disable automatic manage
    ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.update(false);

    // Set manual order without Dashboard
    final orderedModules = [
      ZagModule.DISCOVER,
      ZagModule.SERVER,
      ZagModule.RADARR,
      ZagModule.SONARR,
      ZagModule.LIDARR,
      ZagModule.SABNZBD,
      ZagModule.NZBGET,
      ZagModule.TAUTULLI,
      ZagModule.EXTERNAL_MODULES,
    ];
    ZagreusDatabase.DRAWER_MANUAL_ORDER.update(orderedModules);

    // External module demo entry (from Supabase)
    if (demoConfig['external_module_enabled'] == true) {
      final externalModuleKeys = List.of(ZagBox.externalModules.keys);
      for (final key in externalModuleKeys) {
        await ZagBox.externalModules.delete(key);
      }

      final moduleName = demoConfig['external_module_name'] ?? 'Test';
      final moduleHost = demoConfig['external_module_host'] ?? 'https://zagreus.app';

      await ZagBox.externalModules.update(
        0,
        ZagExternalModule(
          displayName: moduleName,
          host: moduleHost,
        ),
      );
    }

    // Set as active profile
    ZagreusDatabase.ENABLED_PROFILE.update(ZagProfile.DEFAULT_PROFILE);

    showZagSuccessSnackBar(
      title: 'Demo Configuration Loaded',
      message: 'All modules have been configured',
    );
  }
}
