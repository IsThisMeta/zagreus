import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrMoreRoute extends StatefulWidget {
  const RadarrMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<RadarrMoreRoute> createState() => _State();
}

class _State extends State<RadarrMoreRoute> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagListView(
      controller: RadarrNavigationBar.scrollControllers[3],
      itemExtent: ZagBlock.calculateItemExtent(1),
      children: [
        ZagBlock(
          title: 'radarr.History'.tr(),
          body: [TextSpan(text: 'radarr.HistoryDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.history_rounded,
            color: ZagColours().byListIndex(0),
          ),
          onTap: RadarrRoutes.HISTORY.go,
        ),
        ZagBlock(
          title: 'radarr.ManualImport'.tr(),
          body: [TextSpan(text: 'radarr.ManualImportDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.download_done_rounded,
            color: ZagColours().byListIndex(1),
          ),
          onTap: RadarrRoutes.MANUAL_IMPORT.go,
        ),
        ZagBlock(
          title: 'radarr.Queue'.tr(),
          body: [TextSpan(text: 'radarr.QueueDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.queue_play_next_rounded,
            color: ZagColours().byListIndex(2),
          ),
          onTap: RadarrRoutes.QUEUE.go,
        ),
        ZagBlock(
          title: 'radarr.SystemStatus'.tr(),
          body: [TextSpan(text: 'radarr.SystemStatusDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.computer_rounded,
            color: ZagColours().byListIndex(3),
          ),
          onTap: RadarrRoutes.SYSTEM_STATUS.go,
        ),
        ZagBlock(
          title: 'radarr.Tags'.tr(),
          body: [TextSpan(text: 'radarr.TagsDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.style_rounded,
            color: ZagColours().byListIndex(4),
          ),
          onTap: RadarrRoutes.TAGS.go,
        ),
      ],
    );
  }
}
