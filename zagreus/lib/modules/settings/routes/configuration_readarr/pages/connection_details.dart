import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationReadarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationReadarrConnectionDetailsRoute({
    super.key,
  });

  @override
  State<ConfigurationReadarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationReadarrConnectionDetailsRoute>
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
    String host = ZagProfile.current.readarrHost;
    return ZagBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final result = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (result.item1) {
          ZagProfile.current.readarrHost = result.item2;
          ZagProfile.current.save();
          context.read<ReadarrState>().reset();
        }
      },
    );
  }

  Widget _localHost() {
    final profile = ZagProfile.current;
    final host = profile.readarrLocalHost;
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
          profile.readarrLocalHost = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid();
          context.read<ReadarrState>().reset();
        }
      },
    );
  }

  Widget _localSsids() {
    final profile = ZagProfile.current;
    final ssids = profile.readarrLocalSsids;
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
          profile.readarrLocalSsids = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid();
          context.read<ReadarrState>().reset();
        }
      },
    );
  }

  Widget _connectionStatus() {
    final localService = ZagLocalConnectionService();

    return ValueListenableBuilder<String?>(
      valueListenable: localService.currentSsid,
      builder: (context, ssid, _) {
        final profile = ZagProfile.current;
        final advancedEnabled =
            ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
        final hasLocalHost = profile.readarrLocalHost.isNotEmpty;
        final hasSsids = profile.readarrLocalSsids.trim().isNotEmpty;
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

        final effectiveHost = profile.effectiveReadarrHost();
        final networkLabel = ssid ?? 'network.UnknownSsid'.tr();
        final usingLocal = effectiveHost == profile.readarrLocalHost;

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
    String apiKey = ZagProfile.current.readarrKey;
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
        final result = await ZagDialogs().editText(
          context,
          'settings.ApiKey'.tr(),
          prefill: apiKey,
        );
        if (result.item1) {
          ZagProfile.current.readarrKey = result.item2;
          ZagProfile.current.save();
          context.read<ReadarrState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: Icons.wifi_tethering_rounded,
      onTap: () async {
        final profile = ZagProfile.current;
        if (profile.readarrHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'.tr(
              args: [ZagModule.READARR.title],
            ),
          );
          return;
        }
        if (profile.readarrKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'.tr(
              args: [ZagModule.READARR.title],
            ),
          );
          return;
        }

        ReadarrAPI.from(profile)
            .testConnection()
            .then(
              (_) => showZagSuccessSnackBar(
                title: 'settings.ConnectedSuccessfully'.tr(),
                message: 'settings.ConnectedSuccessfullyMessage'.tr(
                  args: [ZagModule.READARR.title],
                ),
              ),
            )
            .catchError((error, stack) {
          ZagLogger().error(
            'Readarr Connection Test Failed',
            error,
            stack,
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
      onTap: SettingsRoutes.CONFIGURATION_READARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
