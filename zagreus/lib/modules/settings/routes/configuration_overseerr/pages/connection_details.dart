import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/modules/settings.dart';

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
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          _host(),
          _apiKey(),
        ],
      ),
    );
  }

  Widget _host() {
    String host = ZagProfile.current.overseerrHost;
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
          ZagProfile.current.overseerrHost = _values.item2;
          ZagProfile.current.save();
          context.read<OverseerrState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.current.overseerrKey;
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
          ZagProfile.current.overseerrKey = _values.item2;
          ZagProfile.current.save();
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
        final profile = ZagProfile.current;
        final host = profile.overseerrHost;
        final apiKey = profile.overseerrKey;

        if (host.isEmpty) {
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
