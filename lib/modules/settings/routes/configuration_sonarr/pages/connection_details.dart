import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationSonarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationSonarrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSonarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationSonarrConnectionDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'settings.ConnectionDetails'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        _testConnection(),
      ],
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBox.zagreus.listenableBuilder(
        selectItems: const [
          ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED,
        ],
        builder: (context, __) {
          final advanced =
              ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
          return ZagListView(
            controller: scrollController,
            children: [
              if (advanced) ZagHeader(text: 'settings.RemoteConnection'.tr()),
              ..._remoteBlocks(),
              if (advanced) ...[
                ZagHeader(text: 'settings.LocalConnection'.tr()),
                ..._localBlocks(),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _remoteBlocks() => [
        _remoteHost(),
        _apiKey(),
        _customHeaders(),
      ];

  List<Widget> _localBlocks() => [
        _localHost(),
        _localSsids(),
        _connectionStatus(),
      ];

  Widget _remoteHost() {
    String host = ZagProfile.forModule('sonarr').sonarrHost;
    return ZagBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (_values.item1) {
          ZagProfile.forModule('sonarr').sonarrHost = _values.item2;
          ZagProfile.forModule('sonarr').save();
          context.read<SonarrState>().reset();
          // Sync webhook if user is authenticated
          _syncWebhook();
        }
      },
    );
  }

  Widget _localHost() {
    final profile = ZagProfile.forModule('sonarr');
    final host = profile.sonarrLocalHost;
    return ZagBlock(
      title: 'settings.LocalHost'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (result.item1) {
          profile.sonarrLocalHost = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<SonarrState>().reset();
        }
      },
    );
  }

  Widget _localSsids() {
    final profile = ZagProfile.forModule('sonarr');
    final ssids = profile.sonarrLocalSsids;
    return ZagBlock(
      title: 'settings.TrustedSsids'.tr(),
      body: [
        TextSpan(
          text: ssids.isEmpty ? 'settings.TrustedSsidsDescription'.tr() : ssids,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await ZagDialogs().editText(
          context,
          'settings.TrustedSsids'.tr(),
          prefill: ssids,
          extraText: [
            TextSpan(text: 'settings.TrustedSsidsHint'.tr()),
          ],
        );
        if (result.item1) {
          profile.sonarrLocalSsids = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<SonarrState>().reset();
        }
      },
    );
  }

  Widget _connectionStatus() {
    final localService = ZagLocalConnectionService();

    return ValueListenableBuilder<String?>(
      valueListenable: localService.currentSsid,
      builder: (context, ssid, _) {
        final profile = ZagProfile.forModule('sonarr');
        final advancedEnabled =
            ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
        final hasLocalHost = profile.sonarrLocalHost.isNotEmpty;
        final hasSsids = profile.sonarrLocalSsids.trim().isNotEmpty;
        final localConfigured = advancedEnabled && hasLocalHost && hasSsids;

        final title = 'settings.ConnectionStatus'.tr();

        if (!localConfigured) {
          return ZagBlock(
            title: title,
            body: [
              TextSpan(
                text: 'settings.ConnectionStatusRemoteOnly'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          );
        }

        final effectiveHost = profile.effectiveSonarrHost();
        final networkLabel = ssid ?? 'network.UnknownSsid'.tr();
        final usingLocal = effectiveHost == profile.sonarrLocalHost;

        final statusText = usingLocal
            ? 'settings.ConnectionStatusLocal'.tr(args: [networkLabel])
            : 'settings.ConnectionStatusRemote'.tr(args: [networkLabel]);

        return ZagBlock(
          title: title,
          body: [
            TextSpan(
              text: statusText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.forModule('sonarr').sonarrKey;
    return ZagBlock(
      title: 'settings.ApiKey'.tr(),
      body: [
        TextSpan(
          text: apiKey.isEmpty
              ? 'zagreus.NotSet'.tr()
              : ZagUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.ApiKey'.tr(),
          prefill: apiKey,
        );
        if (_values.item1) {
          ZagProfile.forModule('sonarr').sonarrKey = _values.item2;
          ZagProfile.forModule('sonarr').save();
          context.read<SonarrState>().reset();
          // Sync webhook if user is authenticated
          _syncWebhook();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZagIcons.CONNECTION_TEST,
      onTap: () async {
        ZagProfile _profile = ZagProfile.forModule('sonarr');
        final effectiveHost = _profile.effectiveSonarrHost();
        if (effectiveHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          return;
        }
        if (_profile.sonarrKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          return;
        }
        SonarrAPI(
          host: effectiveHost,
          apiKey: _profile.sonarrKey,
          headers: Map<String, dynamic>.from(
            _profile.sonarrHeaders,
          ),
        ).system.getStatus().then((_) {
          showZagSuccessSnackBar(
            title: 'settings.ConnectedSuccessfully'.tr(),
            message: 'settings.ConnectedSuccessfullyMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          // Sync webhook after successful connection
          _syncWebhook();
        }).catchError((error, trace) {
          ZagLogger().error(
            'Connection Test Failed',
            error,
            trace,
          );
          showZagErrorSnackBar(
            title: 'settings.ConnectionTestFailed'.tr(),
            error: error,
          );
        });
      },
    );
  }

  Widget _customHeaders() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported &&
          ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.forModule('sonarr');
        final effectiveHost = profile.effectiveSonarrHost();
        if (profile.sonarrEnabled &&
            effectiveHost.isNotEmpty &&
            profile.sonarrKey.isNotEmpty) {
          ZagLogger()
              .debug('Syncing Sonarr webhook after configuration change');
          final api = SonarrAPI(
            host: effectiveHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          await SonarrWebhookManager.syncWebhook(api);
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook after configuration', e, stack);
    }

    // Check if we should trigger notification prompt
    _checkBothModulesConfigured();
  }

  void _checkBothModulesConfigured() {
    // Only check if we haven't shown the prompt yet
    if (ZagreusDatabase.HAS_SHOWN_NOTIFICATION_PROMPT.read()) {
      return;
    }

    final profile = ZagProfile.forModule('sonarr');
    final radarrProfile = ZagProfile.forModule('radarr');

    // Check if both Sonarr and Radarr are configured with valid credentials
    final sonarrConfigured = profile.sonarrEnabled &&
        profile.effectiveSonarrHost().isNotEmpty &&
        profile.sonarrKey.isNotEmpty;

    final radarrConfigured = radarrProfile.radarrEnabled &&
        radarrProfile.effectiveRadarrHost().isNotEmpty &&
        radarrProfile.radarrKey.isNotEmpty;

    // If both are configured, set the flag to show prompt on next app start
    if (sonarrConfigured && radarrConfigured) {
      ZagreusDatabase.SHOULD_SHOW_NOTIFICATION_PROMPT.update(true);
    }
  }
}
