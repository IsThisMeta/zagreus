import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';

class SABnzbdHistory extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const SABnzbdHistory({
    Key? key,
    required this.refreshIndicatorKey,
  }) : super(key: key);

  @override
  State<SABnzbdHistory> createState() => _State();
}

class _State extends State<SABnzbdHistory>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<SABnzbdHistoryData>>? _future;
  List<SABnzbdHistoryData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    if (mounted) setState(() => _results = []);
    final _api = SABnzbdAPI.from(ZagProfile.current);
    if (mounted)
      setState(() {
        _future = _api.getHistory();
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      appBar: _appBar() as PreferredSizeWidget?,
    );
  }

  Widget _appBar() {
    return ZagAppBar.empty(
      child: SABnzbdHistorySearchBar(
          scrollController: SABnzbdNavigationBar.scrollControllers[1]),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: widget.refreshIndicatorKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<SABnzbdHistoryData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  return ZagMessage.error(
                      onTap: widget.refreshIndicatorKey.currentState!.show);
                }
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
  }

  Widget get _list {
    if (_results?.isEmpty ?? true) {
      return ZagMessage(
        text: 'No History Found',
        buttonText: 'Refresh',
        onTap: loadCallback,
      );
    }
    return Selector<SABnzbdState, Tuple2<String, bool>>(
      selector: (_, model) => Tuple2(
        model.historySearchFilter,
        model.historyHideFailed,
      ),
      builder: (context, data, _) {
        List<SABnzbdHistoryData> _filtered = _filter(data.item1);
        _filtered = data.item2 ? _hide(_filtered) : _filtered;
        return _listBody(_filtered);
      },
    );
  }

  Widget _listBody(List filtered) {
    if (filtered.isEmpty)
      return ZagListView(
        controller: SABnzbdNavigationBar.scrollControllers[1],
        children: [
          ZagMessage.inList(text: 'No History Found'),
        ],
      );
    return ZagListViewBuilder(
      controller: SABnzbdNavigationBar.scrollControllers[1],
      itemCount: filtered.length,
      itemBuilder: (context, index) => SABnzbdHistoryTile(
        data: filtered[index],
        refresh: loadCallback,
      ),
    );
  }

  List<SABnzbdHistoryData> _filter(String filter) => _results!
      .where((entry) => filter.isEmpty
          ? true
          : entry.name.toLowerCase().contains(filter.toLowerCase()))
      .toList();

  List<SABnzbdHistoryData> _hide(List<SABnzbdHistoryData> data) {
    if (data.isEmpty) return data;
    return data.where((entry) => entry.failed).toList();
  }
}
