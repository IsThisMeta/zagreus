import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationOverseerrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationOverseerrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationOverseerrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationOverseerrConnectionDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      // Ensure we have the latest SSID when the page opens so status renders immediately.
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
      ];

  List<Widget> _localBlocks() => [
        _localHost(),
        _localSsids(),
        _connectionStatus(),
      ];

  Widget _remoteHost() {
    String host = ZagProfile.forModule('overseerr').overseerrHost;
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
          ZagProfile.forModule('overseerr').overseerrHost = _values.item2;
          ZagProfile.forModule('overseerr').save();
          context.read<OverseerrState>().reset();
        }
      },
    );
  }

  Widget _localHost() {
    final profile = ZagProfile.forModule('overseerr');
    final host = profile.overseerrLocalHost;
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
          profile.overseerrLocalHost = result.item2;
          profile.save();
          ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<OverseerrState>().resetProfile();
        }
      },
    );
  }

  Widget _localSsids() {
    final profile = ZagProfile.forModule('overseerr');
    final ssids = profile.overseerrLocalSsids;
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
          profile.overseerrLocalSsids = result.item2;
          profile.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<OverseerrState>().resetProfile();
        }
      },
    );
  }

  Widget _connectionStatus() {
    final localService = ZagLocalConnectionService();

    return ValueListenableBuilder<String?>(
      valueListenable: localService.currentSsid,
      builder: (context, ssid, _) {
        final profile = ZagProfile.forModule('overseerr');
        final advancedEnabled =
            ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
        final hasLocalHost = profile.overseerrLocalHost.isNotEmpty;
        final hasSsids = profile.overseerrLocalSsids.trim().isNotEmpty;
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

        final effectiveHost = profile.effectiveOverseerrHost();
        final networkLabel = ssid ?? 'network.UnknownSsid'.tr();
        final usingLocal = effectiveHost == profile.overseerrLocalHost;

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
    String apiKey = ZagProfile.forModule('overseerr').overseerrKey;
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
          ZagProfile.forModule('overseerr').overseerrKey = _values.item2;
          ZagProfile.forModule('overseerr').save();
          context.read<OverseerrState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZagIcons.CONNECTION_TEST,
      onTap: () async {
        final profile = ZagProfile.forModule('overseerr');
        final effectiveHost = profile.effectiveOverseerrHost();
        final apiKey = profile.overseerrKey;

        if (effectiveHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.OVERSEERR.title]),
          );
          return;
        }
        if (apiKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZagModule.OVERSEERR.title]),
          );
          return;
        }

        try {
          final state = context.read<OverseerrState>();
          if (state.api == null) {
            throw Exception('API not initialized');
          }

          // Test connection by fetching status
          final status = await GetOverseerrStatus(state.api!, Dio())();

          showZagSuccessSnackBar(
            title: 'settings.ConnectedSuccessfully'.tr(),
            message: 'settings.ConnectedSuccessfullyMessage'
                .tr(args: [ZagModule.OVERSEERR.title, status.version]),
          );
        } catch (error, stack) {
          ZagLogger()
              .error('Failed to test Overseerr connection', error, stack);
          showZagErrorSnackBar(
            title: 'settings.ConnectionTestFailed'.tr(),
            error: error,
          );
        }
      },
    );
  }
}
