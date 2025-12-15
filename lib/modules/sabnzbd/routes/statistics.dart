import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/sabnzbd.dart';

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
  Future<SABnzbdStatisticsData>? _future;
  SABnzbdStatisticsData? _data;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar as PreferredSizeWidget?,
        body: _body,
      );

  Future<SABnzbdStatisticsData> _fetch() async =>
      SABnzbdAPI.from(ZagProfile.current).getStatistics();

  Future<void> _refresh() async {
    if (mounted)
      setState(() {
        _future = _fetch();
      });
  }

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
          builder: (context, AsyncSnapshot<SABnzbdStatisticsData> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null)
                    return ZagMessage.error(onTap: _refresh);
                  _data = snapshot.data;
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
          _status(),
          const ZagHeader(text: 'Statistics'),
          _statistics(),
          ..._serverStatistics(),
        ],
      );

  Widget _status() {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'Uptime', body: _data!.uptime),
        ZagTableContent(title: 'Version', body: _data!.version),
        ZagTableContent(
            title: 'Temp. Space',
            body: '${_data!.tempFreespace.toString()} GB'),
        ZagTableContent(
            title: 'Final Space',
            body: '${_data!.finalFreespace.toString()} GB'),
      ],
    );
  }

  Widget _statistics() {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'Daily', body: _data!.dailyUsage.asBytes()),
        ZagTableContent(title: 'Weekly', body: _data!.weeklyUsage.asBytes()),
        ZagTableContent(title: 'Monthly', body: _data!.monthlyUsage.asBytes()),
        ZagTableContent(title: 'Total', body: _data!.totalUsage.asBytes()),
      ],
    );
  }

  List<Widget> _serverStatistics() {
    return _data!.servers
        .map((server) => [
              ZagHeader(text: server.name),
              ZagTableCard(
                content: [
                  ZagTableContent(
                      title: 'Daily', body: server.dailyUsage.asBytes()),
                  ZagTableContent(
                      title: 'Weekly', body: server.weeklyUsage.asBytes()),
                  ZagTableContent(
                      title: 'Monthly', body: server.monthlyUsage.asBytes()),
                  ZagTableContent(
                      title: 'Total', body: server.totalUsage.asBytes()),
                ],
              ),
            ])
        .expand((element) => element)
        .toList();
  }
}
