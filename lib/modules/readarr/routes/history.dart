import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrHistory extends StatefulWidget {
  static const ROUTE_NAME = '/readarr/history';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const ReadarrHistory({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<ReadarrHistory> createState() => _State();
}

class _State extends State<ReadarrHistory> with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<ReadarrHistoryData>>? _future;
  List<ReadarrHistoryData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _results = [];
    final _api = ReadarrAPI.from(ZagProfile.current);
    if (mounted)
      setState(() {
        _future = _api.getHistory();
      });
  }

  void _refreshAllPages() => widget.refreshAllPages();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: widget.refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<ReadarrHistoryData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  return ZagMessage.error(
                      onTap: () =>
                          widget.refreshIndicatorKey.currentState?.show);
                }
                _results = snapshot.data;
                return _list();
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
  }

  Widget _list() {
    if ((_results?.length ?? 0) == 0)
      return ZagMessage(
        text: 'No History',
        buttonText: 'Refresh',
        onTap: widget.refreshIndicatorKey.currentState?.show,
      );
    return Scrollbar(
      child: ListView.builder(
        controller: ReadarrNavigationBar.scrollControllers[2],
        itemCount: _results!.length,
        itemBuilder: (context, index) {
          return ReadarrHistoryTile(data: _results![index]);
        },
      ),
    );
  }
}
