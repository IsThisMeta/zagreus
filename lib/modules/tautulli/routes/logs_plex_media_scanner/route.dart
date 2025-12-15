import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class LogsPlexMediaScannerRoute extends StatefulWidget {
  const LogsPlexMediaScannerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LogsPlexMediaScannerRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TautulliLogsPlexMediaScannerState(context),
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'Plex Media Scanner Logs',
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<TautulliLogsPlexMediaScannerState>().fetchLogs(context),
      child: FutureBuilder(
        future: context
            .select((TautulliLogsPlexMediaScannerState state) => state.logs),
        builder: (context, AsyncSnapshot<List<TautulliPlexLog>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Plex Media Scanner logs',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _logs(snapshot.data);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _logs(List<TautulliPlexLog>? logs) {
    if ((logs?.length ?? 0) == 0)
      return ZagMessage(
        text: 'No Logs Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    List<TautulliPlexLog> _reversed = logs!.reversed.toList();
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: _reversed.length,
      itemBuilder: (context, index) =>
          TautulliLogsPlexMediaScannerLogTile(log: _reversed[index]),
    );
  }
}
