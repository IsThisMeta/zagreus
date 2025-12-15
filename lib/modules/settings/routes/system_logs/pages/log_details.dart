import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/log.dart';
import 'package:zagreus/modules/settings/routes/system_logs/widgets/log_tile.dart';
import 'package:zagreus/types/log_type.dart';

class SystemLogsDetailsRoute extends StatefulWidget {
  final ZagLogType? type;

  const SystemLogsDetailsRoute({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<SystemLogsDetailsRoute> createState() => _State();
}

class _State extends State<SystemLogsDetailsRoute>
    with ZagScrollControllerMixin {
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
      title: 'settings.Logs'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagBox.logs.listenableBuilder(builder: (context, _) {
      List<ZagLog> logs = filter();
      if (logs.isEmpty) {
        return ZagMessage.goBack(
          context: context,
          text: 'settings.NoLogsFound'.tr(),
        );
      }
      return ZagListViewBuilder(
        controller: scrollController,
        itemCount: logs.length,
        itemBuilder: (context, index) => SettingsSystemLogTile(
          log: logs[index],
        ),
      );
    });
  }

  List<ZagLog> filter() {
    List<ZagLog> logs;
    const box = ZagBox.logs;

    switch (widget.type) {
      case ZagLogType.WARNING:
        logs =
            box.data.where((log) => log.type == ZagLogType.WARNING).toList();
        break;
      case ZagLogType.ERROR:
        logs = box.data.where((log) => log.type == ZagLogType.ERROR).toList();
        break;
      case ZagLogType.CRITICAL:
        logs =
            box.data.where((log) => log.type == ZagLogType.CRITICAL).toList();
        break;
      case ZagLogType.DEBUG:
        logs = box.data.where((log) => log.type == ZagLogType.DEBUG).toList();
        break;
      default:
        logs = box.data.where((log) => log.type.enabled).toList();
        break;
    }
    logs.sort((a, b) => (b.timestamp).compareTo(a.timestamp));
    return logs;
  }
}
