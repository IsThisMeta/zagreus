import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliHistoryRoute extends StatefulWidget {
  const TautulliHistoryRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliHistoryRoute> createState() => _State();
}

class _State extends State<TautulliHistoryRoute>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().resetHistory();
    await context.read<TautulliState>().history;
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
      child: Selector<TautulliState, Future<TautulliHistory>>(
        selector: (_, state) => state.history!,
        builder: (context, history, _) => FutureBuilder(
          future: history,
          builder: (context, AsyncSnapshot<TautulliHistory> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting)
                ZagLogger().error(
                  'Unable to fetch Tautulli history',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              return ZagMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData) return _history(snapshot.data);
            return const ZagLoader();
          },
        ),
      ),
    );
  }

  Widget _history(TautulliHistory? history) {
    if ((history?.records?.length ?? 0) == 0)
      return ZagMessage(
        text: 'No History Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState!.show,
      );
    return ZagListViewBuilder(
      controller: TautulliNavigationBar.scrollControllers[2],
      itemCount: history!.records!.length,
      itemExtent: ZagBlock.calculateItemExtent(3),
      itemBuilder: (context, index) =>
          TautulliHistoryTile(history: history.records![index]),
    );
  }
}
