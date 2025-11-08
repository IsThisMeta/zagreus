import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliActivityRoute extends StatefulWidget {
  const TautulliActivityRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliActivityRoute> createState() => _State();
}

class _State extends State<TautulliActivityRoute>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<TautulliState>().resetActivity();
    await context.read<TautulliState>().activity;
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
        future: context.select<TautulliState, Future<TautulliActivity?>>(
            (state) => state.activity!),
        builder: (context, AsyncSnapshot<TautulliActivity?> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Tautulli activity',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(TautulliActivity? activity) {
    if ((activity?.sessions?.length ?? 0) == 0)
      return ZagMessage(
        text: 'tautulli.NoActiveStreams'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    return ZagListView(
      controller: TautulliNavigationBar.scrollControllers[0],
      children: [
        TautulliActivityStatus(activity: activity),
        ...List.generate(
          activity!.sessions!.length,
          (index) => TautulliActivityTile(session: activity.sessions![index]),
        ),
      ],
    );
  }
}
