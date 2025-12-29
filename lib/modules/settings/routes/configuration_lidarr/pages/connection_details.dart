import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationLidarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationLidarrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationLidarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationLidarrConnectionDetailsRoute>
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
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
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
    String host = ZagProfile.forModule('lidarr').lidarrHost;
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
          ZagProfile.forModule('lidarr').lidarrHost = _values.item2;
          ZagProfile.forModule('lidarr').save();
          context.read<LidarrState>().reset();
          // Sync webhook if user is authenticated
          _syncWebhook();
        }
      },
    );
  }

  Widget _localHost() {
    final profile = ZagProfile.forModule('lidarr');
    final host = profile.lidarrLocalHost;
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
          profile.lidarrLocalHost = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _localSsids() {
    final profile = ZagProfile.forModule('lidarr');
    final ssids = profile.lidarrLocalSsids;
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
          extraText: [TextSpan(text: 'settings.TrustedSsidsHint'.tr())],
        );
        if (result.item1) {
          profile.lidarrLocalSsids = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<LidarrState>().reset();
        }
      },
    );
  }

  Widget _connectionStatus() {
    final localService = ZagLocalConnectionService();

    return ValueListenableBuilder<String?>(
      valueListenable: localService.currentSsid,
      builder: (context, ssid, _) {
        final profile = ZagProfile.forModule('lidarr');
        final advancedEnabled =
            ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
        final hasLocalHost = profile.lidarrLocalHost.isNotEmpty;
        final hasSsids = profile.lidarrLocalSsids.trim().isNotEmpty;
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

        final effectiveHost = profile.effectiveLidarrHost();
        final networkLabel = ssid ?? 'network.UnknownSsid'.tr();
        final usingLocal = effectiveHost == profile.lidarrLocalHost;

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
    String apiKey = ZagProfile.forModule('lidarr').lidarrKey;
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
          ZagProfile.forModule('lidarr').lidarrKey = _values.item2;
          ZagProfile.forModule('lidarr').save();
          context.read<LidarrState>().reset();
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
        ZagProfile _profile = ZagProfile.forModule('lidarr');
        final effectiveHost = _profile.effectiveLidarrHost();
        if (effectiveHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'.tr(
              args: [ZagModule.LIDARR.title],
            ),
          );
          return;
        }
        if (_profile.lidarrKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'.tr(
              args: [ZagModule.LIDARR.title],
            ),
          );
          return;
        }
        LidarrAPI.from(ZagProfile.current)
            .testConnection()
            .then(
              (_) {
            showZagSuccessSnackBar(
              title: 'settings.ConnectedSuccessfully'.tr(),
              message: 'settings.ConnectedSuccessfullyMessage'.tr(
                args: [ZagModule.LIDARR.title],
              ),
            );
            // Sync webhook after successful connection
            _syncWebhook();
          },
            )
            .catchError((error, trace) {
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
      onTap: SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported &&
          ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.forModule('lidarr');
        final effectiveHost = profile.effectiveLidarrHost();
        if (profile.lidarrEnabled &&
            effectiveHost.isNotEmpty &&
            profile.lidarrKey.isNotEmpty) {
          ZagLogger()
              .debug('Syncing Lidarr webhook after configuration change');
          final client = Dio(
            BaseOptions(
              baseUrl: effectiveHost.endsWith('/')
                  ? '${effectiveHost}api/v1/'
                  : '$effectiveHost/api/v1/',
              queryParameters: {
                'apikey': profile.lidarrKey,
              },
              headers: Map<String, dynamic>.from(profile.lidarrHeaders),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          await LidarrWebhookManager.syncWebhook(client);
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook after configuration', e, stack);
    }
  }
}
