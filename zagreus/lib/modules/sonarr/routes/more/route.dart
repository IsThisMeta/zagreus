import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrMoreRoute extends StatefulWidget {
  const SonarrMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrMoreRoute> createState() => _State();
}

class _State extends State<SonarrMoreRoute> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SONARR,
      body: _body(),
    );
  }

  // ignore: unused_element
  Future<void> _showComingSoonMessage() async {
    showZagInfoSnackBar(
      title: 'zagreus.ComingSoon'.tr(),
      message: 'This feature is still being developed!',
    );
  }

  Widget _body() {
    return ZagListView(
      controller: SonarrNavigationBar.scrollControllers[3],
      children: [
        ZagBlock(
          title: 'sonarr.History'.tr(),
          body: [TextSpan(text: 'sonarr.HistoryDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.history_rounded,
            color: ZagColours().byListIndex(0),
          ),
          onTap: SonarrRoutes.HISTORY.go,
        ),
        // ZagBlock(
        //   title: 'sonarr.ManualImport'.tr(),
        //   body: [TextSpan(text: 'sonarr.ManualImportDescription'.tr())],
        //   trailing: ZagIconButton(
        //     icon: Icons.download_done_rounded,
        //     color: ZagColours().byListIndex(1),
        //   ),
        //   onTap: () async => _showComingSoonMessage(),
        // ),
        ZagBlock(
          title: 'sonarr.Queue'.tr(),
          body: [TextSpan(text: 'sonarr.QueueDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.queue_play_next_rounded,
            color: ZagColours.currentAccent,
          ),
          onTap: SonarrRoutes.QUEUE.go,
        ),
        // ZagBlock(
        //   title: 'sonarr.SystemStatus'.tr(),
        //   body: [TextSpan(text: 'sonarr.SystemStatusDescription'.tr())],
        //   trailing: ZagIconButton(
        //     icon: Icons.computer_rounded,
        //     color: ZagColours().byListIndex(3),
        //   ),
        //   onTap: () async => _showComingSoonMessage(),
        // ),
        ZagBlock(
          title: 'sonarr.Tags'.tr(),
          body: [TextSpan(text: 'sonarr.TagsDescription'.tr())],
          trailing: ZagIconButton(
            icon: Icons.style_rounded,
            color: ZagColours().byListIndex(2),
          ),
          onTap: SonarrRoutes.TAGS.go,
        ),
      ],
    );
  }
}
