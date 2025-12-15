import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliUserDetailsSyncedItems extends StatefulWidget {
  final TautulliTableUser user;

  const TautulliUserDetailsSyncedItems({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliUserDetailsSyncedItems>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().setUserSyncedItems(
          widget.user.userId!,
          context
              .read<TautulliState>()
              .api!
              .libraries
              .getSyncedItems(userId: widget.user.userId),
        );
    await context.read<TautulliState>().userSyncedItems[widget.user.userId!];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.TAUTULLI,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future:
            context.watch<TautulliState>().userSyncedItems[widget.user.userId!],
        builder: (context, AsyncSnapshot<List<TautulliSyncedItem>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Tautulli user synced items: ${widget.user.userId}',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _syncedItems(snapshot.data);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _syncedItems(List<TautulliSyncedItem>? items) {
    if ((items?.length ?? 0) == 0)
      return ZagMessage(
        text: 'No Synced Items Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState!.show,
      );
    return ZagListViewBuilder(
      controller: TautulliUserDetailsNavigationBar.scrollControllers[2],
      itemCount: items!.length,
      itemBuilder: (context, index) =>
          TautulliSyncedItemTile(syncedItem: items[index]),
    );
  }
}
