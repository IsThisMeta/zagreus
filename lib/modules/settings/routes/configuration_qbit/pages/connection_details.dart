import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

class ConfigurationQBitConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationQBitConnectionDetailsRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationQBitConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationQBitConnectionDetailsRoute>
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
        _username(),
        _password(),
        _customHeaders(),
      ];

  List<Widget> _localBlocks() => [
        _localHost(),
        _localSsids(),
        _connectionStatus(),
      ];

  Widget _remoteHost() {
    String host = ZagProfile.current.qbitHost;
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
          ZagProfile.current.qbitHost = _values.item2;
          ZagProfile.current.save();
          context.read<QBitState>().reset();
        }
      },
    );
  }

  Widget _username() {
    String username = ZagProfile.current.qbitUser;
    return ZagBlock(
      title: 'settings.Username'.tr(),
      body: [
        TextSpan(text: username.isEmpty ? 'zagreus.NotSet'.tr() : username),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.Username'.tr(),
          prefill: username,
        );
        if (_values.item1) {
          ZagProfile.current.qbitUser = _values.item2;
          ZagProfile.current.save();
          context.read<QBitState>().reset();
        }
      },
    );
  }

  Widget _password() {
    String password = ZagProfile.current.qbitPass;
    return ZagBlock(
      title: 'settings.Password'.tr(),
      body: [
        TextSpan(
          text: password.isEmpty
              ? 'zagreus.NotSet'.tr()
              : ZagUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.Password'.tr(),
          prefill: password,
          extraText: [
            ZagDialog.textSpanContent(
              text: '${ZagUI.TEXT_BULLET} ${'settings.PasswordHint1'.tr()}',
            ),
          ],
        );
        if (_values.item1) {
          ZagProfile.current.qbitPass = _values.item2;
          ZagProfile.current.save();
          context.read<QBitState>().reset();
        }
      },
    );
  }

  Widget _customHeaders() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_QBIT_CONNECTION_DETAILS_HEADERS.go,
    );
  }

  Widget _localHost() {
    String localHost = ZagProfile.current.qbitLocalHost;
    return ZagBlock(
      title: 'settings.LocalHost'.tr(),
      body: [
        TextSpan(text: localHost.isEmpty ? 'zagreus.NotSet'.tr() : localHost)
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: localHost,
        );
        if (_values.item1) {
          ZagProfile.current.qbitLocalHost = _values.item2;
          ZagProfile.current.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<QBitState>().reset();
        }
      },
    );
  }

  Widget _localSsids() {
    String ssids = ZagProfile.current.qbitLocalSsids;
    return ZagBlock(
      title: 'settings.TrustedSsids'.tr(),
      body: [
        TextSpan(
          text: ssids.isEmpty ? 'settings.TrustedSsidsDescription'.tr() : ssids,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.TrustedSsids'.tr(),
          prefill: ssids,
          extraText: [TextSpan(text: 'settings.TrustedSsidsHint'.tr())],
        );
        if (_values.item1) {
          ZagProfile.current.qbitLocalSsids = _values.item2;
          ZagProfile.current.save();
          await ZagLocalConnectionService().refreshSsid(forceEvaluate: true);
          context.read<QBitState>().reset();
        }
      },
    );
  }

  Widget _connectionStatus() {
    final localService = ZagLocalConnectionService();

    return ValueListenableBuilder<String?>(
      valueListenable: localService.currentSsid,
      builder: (context, ssid, _) {
        final advancedEnabled =
            ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read();
        final hasLocalHost = ZagProfile.current.qbitLocalHost.isNotEmpty;
        final hasSsids = ZagProfile.current.qbitLocalSsids.trim().isNotEmpty;
        final localConfigured = advancedEnabled && hasLocalHost && hasSsids;

        final title = 'settings.ConnectionStatus'.tr();

        if (!localConfigured) {
          return ZagBlock(
            title: title,
            body: [TextSpan(text: 'settings.NotConfigured'.tr())],
          );
        }

        final trustedSsids = ZagProfile.current.qbitLocalSsids
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        final isLocal = ssid != null && trustedSsids.contains(ssid);

        return ZagBlock(
          title: title,
          body: [
            TextSpan(
              text: isLocal
                  ? 'settings.UsingLocalConnection'.tr()
                  : 'settings.UsingRemoteConnection'.tr(),
            ),
            if (ssid != null) ...[
              const TextSpan(text: '\n'),
              TextSpan(
                text: 'settings.CurrentSSID'.tr(args: [ssid]),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZagIcons.CONNECTION_TEST,
      onTap: () async {
        showZagInfoSnackBar(
          title: 'settings.TestingConnection'.tr(),
          message: '',
        );
        try {
          final api = QBitAPI.from(ZagProfile.current);
          final version = await api.testConnection();
          showZagSuccessSnackBar(
            title: 'settings.ConnectionSuccessful'.tr(),
            message: 'qBittorrent $version',
          );
        } catch (error) {
          showZagErrorSnackBar(
            title: 'settings.ConnectionFailed'.tr(),
            error: error,
          );
        }
      },
    );
  }
}
