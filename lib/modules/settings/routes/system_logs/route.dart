import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';
import 'package:zagreus/types/log_type.dart';

class SystemLogsRoute extends StatefulWidget {
  const SystemLogsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SystemLogsRoute> createState() => _State();
}

class _State extends State<SystemLogsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      title: 'settings.Logs'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        _exportLogs(),
        _clearLogs(),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'settings.AllLogs'.tr(),
          body: [TextSpan(text: 'settings.AllLogsDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.developer_mode_rounded),
          onTap: () async => _viewLogs(null),
        ),
        ...List.generate(
          ZagLogType.values.length,
          (index) {
            if (ZagLogType.values[index].enabled)
              return ZagBlock(
                title: ZagLogType.values[index].title,
                body: [TextSpan(text: ZagLogType.values[index].description)],
                trailing: ZagIconButton(icon: ZagLogType.values[index].icon),
                onTap: () async => _viewLogs(ZagLogType.values[index]),
              );
            return Container(height: 0.0);
          },
        ),
      ],
    );
  }

  Future<void> _viewLogs(ZagLogType? type) async {
    SettingsRoutes.SYSTEM_LOGS_DETAILS.go(params: {
      'type': type?.key ?? 'all',
    });
  }

  Widget _clearLogs() {
    return ZagButton.text(
      text: 'settings.Clear'.tr(),
      icon: ZagIcons.DELETE,
      color: ZagColours.red,
      onTap: () async {
        bool result = await SettingsDialogs().clearLogs(context);
        if (result) {
          ZagLogger().clear();
          showZagSuccessSnackBar(
            title: 'settings.LogsCleared'.tr(),
            message: 'settings.LogsClearedDescription'.tr(),
          );
        }
      },
    );
  }

  Widget _exportLogs() {
    return Builder(
      builder: (context) => ZagButton.text(
        text: 'settings.Export'.tr(),
        icon: ZagIcons.DOWNLOAD,
        onTap: () async {
          String data = await ZagLogger().export();
          bool result = await ZagFileSystem()
              .save(context, 'logs.json', utf8.encode(data));
          if (result)
            showZagSuccessSnackBar(
                title: 'settings.ExportedLogs'.tr(),
                message: 'settings.ExportedLogsMessage'.tr());
        },
      ),
    );
  }
}
