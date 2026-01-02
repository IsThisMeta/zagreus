import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';

class TautulliMoreRoute extends StatefulWidget {
  const TautulliMoreRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliMoreRoute> createState() => _State();
}

class _State extends State<TautulliMoreRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.TAUTULLI,
      body: _body,
    );
  }

  Widget get _body {
    return ZagListView(
      controller: TautulliNavigationBar.scrollControllers[3],
      children: [
        ZagBlock(
          title: 'tautulli.CheckForUpdates'.tr(),
          body: [
            TextSpan(text: 'tautulli.CheckForUpdatesDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.system_update_rounded,
            color: ZagColours().byListIndex(0),
          ),
          onTap: TautulliRoutes.CHECK_FOR_UPDATES.go,
        ),
        ZagBlock(
          title: 'tautulli.Graphs'.tr(),
          body: [
            TextSpan(text: 'tautulli.GraphsDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.insert_chart_rounded,
            color: ZagColours().byListIndex(1),
          ),
          onTap: TautulliRoutes.GRAPHS.go,
        ),
        ZagBlock(
          title: 'tautulli.Libraries'.tr(),
          body: [
            TextSpan(text: 'tautulli.LibrariesDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.video_library_rounded,
            color: ZagColours().byListIndex(2),
          ),
          onTap: TautulliRoutes.LIBRARIES.go,
        ),
        ZagBlock(
          title: 'tautulli.Logs'.tr(),
          body: [
            TextSpan(text: 'tautulli.LogsDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.developer_mode_rounded,
            color: ZagColours().byListIndex(3),
          ),
          onTap: TautulliRoutes.LOGS.go,
        ),
        ZagBlock(
          title: 'tautulli.RecentlyAdded'.tr(),
          body: [
            TextSpan(text: 'tautulli.RecentlyAddedDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.recent_actors_rounded,
            color: ZagColours().byListIndex(4),
          ),
          onTap: TautulliRoutes.RECENTLY_ADDED.go,
        ),
        ZagBlock(
          title: 'tautulli.Search'.tr(),
          body: [
            TextSpan(text: 'tautulli.SearchDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.search_rounded,
            color: ZagColours().byListIndex(5),
          ),
          onTap: TautulliRoutes.SEARCH.go,
        ),
        ZagBlock(
          title: 'tautulli.Statistics'.tr(),
          body: [
            TextSpan(text: 'tautulli.StatisticsDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.format_list_numbered_rounded,
            color: ZagColours().byListIndex(6),
          ),
          onTap: TautulliRoutes.STATISTICS.go,
        ),
        ZagBlock(
          title: 'tautulli.SyncedItems'.tr(),
          body: [
            TextSpan(text: 'tautulli.SyncedItemsDescription'.tr()),
          ],
          trailing: ZagIconButton(
            icon: Icons.sync_rounded,
            color: ZagColours.currentAccent,
          ),
          onTap: TautulliRoutes.SYNCED_ITEMS.go,
        ),
      ],
    );
  }
}
