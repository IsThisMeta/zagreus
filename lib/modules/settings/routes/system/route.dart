import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/backup_tile.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/build_details.dart';
import 'package:zagreus/modules/settings/routes/system/widgets/restore_tile.dart';
import 'package:zagreus/modules/seerr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/auth.dart';
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
      title: 'settings.ReviewDemo'.tr(),
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
        title: Text('settings.ReviewAccess'.tr()),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'settings.ReviewPassword'.tr(),
            hintText: 'settings.ReviewPasswordHint'.tr(),
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
              'zagreus.Cancel'.tr(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: Text(
              'settings.ContinueAction'.tr(),
              style: TextStyle(color: ZagColours.accentColor(context)),
            ),
          ),
        ],
      ),
    );

    // Check password
    if (password != 'review2025') {
      if (password != null) {
        showZagErrorSnackBar(
          title: 'settings.ReviewAccessDenied'.tr(),
          message: 'settings.ReviewInvalidPassword'.tr(),
        );
      }
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.LoadingDemoConfiguration'.tr(),
      message: 'settings.CheckingDemoAvailability'.tr(),
    );

    // Check Supabase for demo config
    final demoConfig = await ZagDemoConfig.fetchDemoConfig();

    if (demoConfig == null || demoConfig['enabled'] != true) {
      showZagErrorSnackBar(
        title: 'settings.DemoUnavailable'.tr(),
        message: 'settings.DemoUnavailableDescription'.tr(),
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

      // Readarr
      readarrEnabled: demoConfig['readarr_enabled'] ?? false,
      readarrHost: demoConfig['readarr_host'] ?? '',
      readarrKey: demoConfig['readarr_key'] ?? '',
      readarrHeaders: {},

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

      // Bazarr
      bazarrEnabled: demoConfig['bazarr_enabled'] ?? false,
      bazarrHost: demoConfig['bazarr_host'] ?? '',
      bazarrKey: demoConfig['bazarr_key'] ?? '',
      bazarrHeaders: {},

      // Tautulli
      tautulliEnabled: demoConfig['tautulli_enabled'] ?? false,
      tautulliHost: demoConfig['tautulli_host'] ?? '',
      tautulliKey: demoConfig['tautulli_key'] ?? '',
      tautulliHeaders: {},

      // Seerr
      seerrEnabled: demoConfig['seerr_enabled'] ?? false,
      seerrHost: demoConfig['seerr_host'] ?? '',
      seerrKey: demoConfig['seerr_key'] ?? '',
      seerrHeaders: {},
      // Unraid
      unraidEnabled: demoConfig['unraid_enabled'] ?? true,
      unraidHost:
          demoConfig['unraid_host'] ?? 'https://tower.zagreus.app/',
      unraidKey: demoConfig['unraid_key'] ??
          '4f881bebb9da6a41431cfa5b194b36fa12094a87b5164886542ddfa2e235066c',
      unraidHeaders: const <String, String>{},

      // SSH
      sshEnabled: demoConfig['ssh_enabled'] ?? false,
    );

    // Save the profile
    await ZagBox.profiles.update(ZagProfile.DEFAULT_PROFILE, profile);

    // Hack: Toggle Radarr, Sonarr, and Seerr states to ensure they reinitialize properly
    if (!mounted) return;

    final radarrState = context.read<RadarrState>();
    final sonarrState = context.read<SonarrState>();
    final seerrState = context.read<SeerrState>();

    // First disable them
    profile.radarrEnabled = false;
    profile.sonarrEnabled = false;
    profile.seerrEnabled = false;
    await ZagBox.profiles.update(ZagProfile.DEFAULT_PROFILE, profile);
    radarrState.reset();
    sonarrState.reset();
    seerrState.reset();

    // Small delay to ensure state update completes
    await Future.delayed(const Duration(milliseconds: 100));

    // Now re-enable them
    profile.radarrEnabled = demoConfig['radarr_enabled'] ?? false;
    profile.sonarrEnabled = demoConfig['sonarr_enabled'] ?? false;
    profile.seerrEnabled = demoConfig['seerr_enabled'] ?? false;
    await ZagBox.profiles.update(ZagProfile.DEFAULT_PROFILE, profile);
    radarrState.reset();
    sonarrState.reset();
    seerrState.reset();

    // Set the drawer order (excluding Dashboard since it's always added automatically)
    // First disable automatic manage
    ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.update(false);

    // Set manual order without Dashboard
    final orderedModules = [
      ZagModule.DISCOVER,
      ZagModule.UNRAID,
      ZagModule.RADARR,
      ZagModule.SONARR,
      ZagModule.LIDARR,
      ZagModule.READARR,
      ZagModule.SABNZBD,
      ZagModule.NZBGET,
      ZagModule.TAUTULLI,
      ZagModule.SEERR,
      ZagModule.SEARCH,
      ZagModule.SSH,
      ZagModule.EXTERNAL_MODULES,
    ];
    ZagreusDatabase.DRAWER_MANUAL_ORDER.update(orderedModules);

    // External module demo entry (from Supabase)
    if (demoConfig['external_module_enabled'] == true) {
      final externalModuleKeys = List.of(ZagBox.externalModules.keys);
      for (final key in externalModuleKeys) {
        await ZagBox.externalModules.delete(key);
      }

      final moduleName =
          demoConfig['external_module_name'] ?? 'settings.DemoExternalModuleName'.tr();
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

    // Create Prowlarr indexer for search module
    final prowlarrEnabled = demoConfig['prowlarr_enabled'] ?? true;
    final prowlarrHost = demoConfig['prowlarr_host'] ?? 'https://prowlarr.scarletmacaw.box.ca';
    final prowlarrKey = demoConfig['prowlarr_key'] ?? '8f0d5a060da944c1a20e4cde56692c1c';

    // Clear existing indexers first
    final indexerKeys = List.of(ZagBox.indexers.keys);
    for (final key in indexerKeys) {
      await ZagBox.indexers.delete(key);
    }

    int indexerIndex = 0;

    if (prowlarrEnabled) {
      // Create Prowlarr indexer
      await ZagBox.indexers.update(
        indexerIndex++,
        ZagIndexer(
          displayName: 'Prowlarr',
          host: prowlarrHost,
          apiKey: prowlarrKey,
          headers: {},
          isProwlarr: true,
        ),
      );
    }

    // Create Search indexer (NZBgeek) if enabled
    final searchEnabled = demoConfig['search_enabled'] ?? false;
    if (searchEnabled) {
      final searchDisplayName = demoConfig['search_display_name'] ?? 'NZBgeek';
      final searchHost = demoConfig['search_host'] ?? '';
      final searchKey = demoConfig['search_key'] ?? '';

      if (searchHost.isNotEmpty) {
        await ZagBox.indexers.update(
          indexerIndex++,
          ZagIndexer(
            displayName: searchDisplayName,
            host: searchHost,
            apiKey: searchKey,
            headers: {},
            isProwlarr: false,
          ),
        );
      }
    }

    // Create SSH connection if enabled
    final sshEnabled = demoConfig['ssh_enabled'] ?? false;
    if (sshEnabled) {
      final sshHost = demoConfig['ssh_host'] ?? '';
      final sshPort = demoConfig['ssh_port'] ?? 22;
      final sshUser = demoConfig['ssh_user'] ?? '';
      final sshPass = demoConfig['ssh_pass'] ?? '';

      if (sshHost.isNotEmpty && sshUser.isNotEmpty) {
        // Clear existing SSH connections
        final sshKeys = List.of(ZagBox.sshConnections.keys);
        for (final key in sshKeys) {
          await ZagBox.sshConnections.delete(key);
        }

        // Create demo SSH connection
        final sshConnection = SSHConnection.create(
          profileId: ZagProfile.DEFAULT_PROFILE,
          name: 'Demo Server',
          host: sshHost,
          port: sshPort,
          username: sshUser,
          authType: SSHAuthType.password,
          password: sshPass,
        );
        await ZagBox.sshConnections.update(sshConnection.id, sshConnection);
      }
    }

    showZagSuccessSnackBar(
      title: 'settings.DemoConfigurationLoaded'.tr(),
      message: 'settings.DemoConfigurationLoadedMessage'.tr(),
    );
  }
}
