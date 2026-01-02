import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrMissing extends StatefulWidget {
  static const ROUTE_NAME = '/readarr/missing';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const ReadarrMissing({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<ReadarrMissing> createState() => _State();
}

class _State extends State<ReadarrMissing> with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<ReadarrMissingData>>? _future;
  List<ReadarrMissingData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _results = [];
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
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
        builder: (context, AsyncSnapshot<List<ReadarrMissingData>> snapshot) {
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
        text: 'readarr.NoMissingBooks'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: widget.refreshIndicatorKey.currentState?.show,
      );
    return Scrollbar(
      child: ListView.builder(
        controller: ReadarrNavigationBar.scrollControllers[1],
        itemCount: _results!.length,
        itemBuilder: (context, index) {
          return ReadarrMissingTile(data: _results![index]);
        },
      ),
    );
  }
}
