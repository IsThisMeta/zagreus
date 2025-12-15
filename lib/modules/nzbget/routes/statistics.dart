import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/nzbget.dart';

class StatisticsRoute extends StatefulWidget {
  const StatisticsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatisticsRoute> createState() => _State();
}

class _State extends State<StatisticsRoute> with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<bool>? _future;
  late NZBGetStatisticsData _statistics;
  List<NZBGetLogData> _logs = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted)
      setState(() {
        _future = _fetch();
      });
  }

  Future<bool> _fetch() async {
    final _api = NZBGetAPI.from(ZagProfile.current);
    return _fetchStatistics(_api)
        .then((_) => _fetchLogs(_api))
        .then((_) => true);
  }

  Future<void> _fetchStatistics(NZBGetAPI api) async {
    return await api.getStatistics().then((stats) {
      _statistics = stats;
    });
  }

  Future<void> _fetchLogs(NZBGetAPI api) async {
    return await api.getLogs().then((logs) {
      _logs = logs;
    });
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar as PreferredSizeWidget?,
        body: _body,
      );

  Widget get _appBar => ZagAppBar(
        title: 'Server Statistics',
        scrollControllers: [scrollController],
      );

  Widget get _body => ZagRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null)
                    return ZagMessage.error(onTap: _refresh);
                  return _list;
                }
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              default:
                return const ZagLoader();
            }
          },
        ),
      );

  Widget get _list => ZagListView(
        controller: scrollController,
        children: <Widget>[
          const ZagHeader(text: 'Status'),
          _statusBlock(),
          const ZagHeader(text: 'Logs'),
          for (var entry in _logs)
            NZBGetLogTile(
              data: entry,
            ),
        ],
      );

  Widget _statusBlock() {
    return ZagTableCard(
      content: [
        ZagTableContent(
            title: 'Server',
            body: _statistics.serverPaused ? 'Paused' : 'Active'),
        ZagTableContent(
            title: 'Post', body: _statistics.postPaused ? 'Paused' : 'Active'),
        ZagTableContent(
            title: 'Scan', body: _statistics.scanPaused ? 'Paused' : 'Active'),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(title: 'Uptime', body: _statistics.uptimeString),
        ZagTableContent(
            title: 'Speed Limit', body: _statistics.speedLimitString),
        ZagTableContent(
            title: 'Free Space', body: _statistics.freeSpaceString),
        ZagTableContent(title: 'Download', body: _statistics.downloadedString),
      ],
    );
  }
}
