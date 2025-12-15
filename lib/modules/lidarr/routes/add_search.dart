import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';

class AddArtistRoute extends StatefulWidget {
  const AddArtistRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AddArtistRoute> createState() => _State();
}

class _State extends State<AddArtistRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<LidarrSearchData>>? _future;
  List<String> _availableIDs = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableArtists();
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body(),
        appBar: _appBar() as PreferredSizeWidget?,
      );

  Future<void> _refresh() async {
    final _model = Provider.of<LidarrState>(context, listen: false);
    final _api = LidarrAPI.from(ZagProfile.current);
    setState(() {
      _future = _api.searchArtists(_model.addSearchQuery);
    });
  }

  Future<void> _fetchAvailableArtists() async {
    await LidarrAPI.from(ZagProfile.current)
        .getAllArtistIDs()
        .then((data) => _availableIDs = data)
        .catchError((error) => _availableIDs = []);
  }

  Widget _appBar() {
    return ZagAppBar(
      scrollControllers: [scrollController],
      title: 'Add Artist',
      bottom: LidarrAddSearchBar(
        callback: _refresh,
        scrollController: scrollController,
      ),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<LidarrSearchData>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.none)
            return Container();
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Lidarr artist lookup',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) return _list(snapshot.data);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(List<LidarrSearchData>? data) {
    if ((data?.length ?? 0) == 0)
      return ZagListView(
        controller: scrollController,
        children: const [ZagMessage(text: 'No Results Found')],
      );
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: data!.length,
      itemBuilder: (context, index) => LidarrAddSearchResultTile(
        data: data[index],
        alreadyAdded: _availableIDs.contains(data[index].foreignArtistId),
      ),
    );
  }
}
