import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class AddAuthorRoute extends StatefulWidget {
  const AddAuthorRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AddAuthorRoute> createState() => _State();
}

class _State extends State<AddAuthorRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<ReadarrSearchData>>? _future;
  List<String> _availableIDs = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableAuthors();
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body(),
        appBar: _appBar() as PreferredSizeWidget?,
      );

  Future<void> _refresh() async {
    final _model = Provider.of<ReadarrState>(context, listen: false);
    final _api = ReadarrAPI.from(ZagProfile.current);
    setState(() {
      _future = _api.searchAuthors(_model.addSearchQuery);
    });
  }

  Future<void> _fetchAvailableAuthors() async {
    await ReadarrAPI.from(ZagProfile.current)
        .getAllAuthorIDs()
        .then((data) => _availableIDs = data)
        .catchError((error) => _availableIDs = []);
  }

  Widget _appBar() {
    return ZagAppBar(
      scrollControllers: [scrollController],
      title: 'Add Author',
      bottom: ReadarrAddSearchBar(
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
        builder: (context, AsyncSnapshot<List<ReadarrSearchData>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.none)
            return Container();
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Readarr author lookup',
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

  Widget _list(List<ReadarrSearchData>? data) {
    if ((data?.length ?? 0) == 0)
      return ZagListView(
        controller: scrollController,
        children: const [ZagMessage(text: 'No Results Found')],
      );
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: data!.length,
      itemBuilder: (context, index) => ReadarrAddSearchResultTile(
        data: data[index],
        alreadyAdded: _availableIDs.contains(data[index].foreignAuthorId),
      ),
    );
  }
}
