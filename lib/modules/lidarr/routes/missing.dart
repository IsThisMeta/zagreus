import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrMissing extends StatefulWidget {
  static const ROUTE_NAME = '/lidarr/missing';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const LidarrMissing({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<LidarrMissing> createState() => _State();
}

class _State extends State<LidarrMissing> with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<LidarrMissingData>>? _future;
  List<LidarrMissingData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _results = [];
    final _api = LidarrAPI.from(ZagProfile.current);
    if (mounted)
      setState(() {
        _future = _api.getMissing();
      });
  }

  void _refreshAllPages() => widget.refreshAllPages();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body,
    );
  }

  Widget get _body => ZagRefreshIndicator(
        context: context,
        key: widget.refreshIndicatorKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot<List<LidarrMissingData>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null)
                    return ZagMessage.error(onTap: _refresh);
                  _results = snapshot.data;
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

  Widget get _list {
    if (_results?.isEmpty ?? true) {
      return ZagMessage(
        text: 'No Missing Albums',
        buttonText: 'Refresh',
        onTap: widget.refreshIndicatorKey.currentState!.show,
      );
    }
    return ZagListViewBuilder(
      controller: LidarrNavigationBar.scrollControllers[1],
      itemCount: _results!.length,
      itemExtent: LidarrMissingTile.extent,
      itemBuilder: (context, index) => LidarrMissingTile(
        scaffoldKey: _scaffoldKey,
        entry: _results![index],
        refresh: _refreshAllPages,
      ),
    );
  }
}
