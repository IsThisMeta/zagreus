import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrCatalogue extends StatefulWidget {
  static const ROUTE_NAME = '/lidarr/catalogue';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const LidarrCatalogue({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<LidarrCatalogue> createState() => _State();
}

class _State extends State<LidarrCatalogue>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<LidarrCatalogueData>>? _future;
  List<LidarrCatalogueData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    if (mounted) setState(() => _results = []);
    final _api = LidarrAPI.from(ZagProfile.current);
    if (mounted) {
      setState(() {
        _future = _api.getAllArtists();
      });
    }
  }

  void _refreshState() => setState(() {});

  void _refreshAllPages() => widget.refreshAllPages();

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
      child: LidarrCatalogueSearchBar(
        scrollController: LidarrNavigationBar.scrollControllers[0],
      ),
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
        builder: (context, AsyncSnapshot<List<LidarrCatalogueData>> snapshot) {
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
        text: 'No Artists Found',
        buttonText: 'Refresh',
        onTap: widget.refreshIndicatorKey.currentState?.show,
      );
    return Consumer<LidarrState>(
      builder: (context, state, _) {
        List<LidarrCatalogueData>? filtered =
            _filterAndSort(_results, state.searchCatalogueFilter);
        if ((filtered?.length ?? 0) == 0)
          return ZagListView(
            controller: LidarrNavigationBar.scrollControllers[0],
            children: [
              ZagMessage.inList(text: 'No Artists Found'),
            ],
          );
        return ZagListViewBuilder(
          controller: LidarrNavigationBar.scrollControllers[0],
          itemCount: filtered!.length,
          itemExtent: ZagBlock.calculateItemExtent(2),
          itemBuilder: (context, index) => LidarrCatalogueTile(
            data: filtered[index],
            scaffoldKey: _scaffoldKey,
            refresh: _refreshAllPages,
            refreshState: _refreshState,
          ),
        );
      },
    );
  }

  List<LidarrCatalogueData>? _filterAndSort(
      List<LidarrCatalogueData>? artists, String query) {
    if ((artists?.length ?? 0) == 0) return artists;
    LidarrCatalogueSorting sorting =
        context.read<LidarrState>().sortCatalogueType;
    bool shouldHide = context.read<LidarrState>().hideUnmonitoredArtists;
    bool ascending = context.read<LidarrState>().sortCatalogueAscending;
    // Filter
    List<LidarrCatalogueData> filtered = artists!.where((artist) {
      if (shouldHide && !artist.monitored!) return false;
      if (query.isNotEmpty)
        return artist.title.toLowerCase().contains(query.toLowerCase());
      return true;
    }).toList();
    filtered = sorting.sort(filtered, ascending);
    return filtered;
  }
}
