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
  Future<List<ReadarrUnifiedSearchResult>>? _future;
  List<String> _availableAuthorIDs = [];
  List<String> _availableBookIDs = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableItems();
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body(),
        appBar: _appBar() as PreferredSizeWidget?,
      );

  Future<void> _refresh() async {
    final _model = Provider.of<ReadarrState>(context, listen: false);
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    setState(() {
      _future = _api.searchUnified(_model.addSearchQuery);
    });
  }

  Future<void> _fetchAvailableItems() async {
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    // Fetch available author IDs
    await _api.getAllAuthorIDs()
        .then((data) => _availableAuthorIDs = data)
        .catchError((error) => _availableAuthorIDs = []);
    // Fetch available book IDs (foreignBookIds from all books)
    await _api.getAllBookIDs()
        .then((data) => _availableBookIDs = data)
        .catchError((error) => _availableBookIDs = []);
  }

  Widget _appBar() {
    return ZagAppBar(
      scrollControllers: [scrollController],
      title: 'readarr.AddAuthorOrBook'.tr(),
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
        builder: (context, AsyncSnapshot<List<ReadarrUnifiedSearchResult>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.none)
            return Container();
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Readarr search results',
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

  Widget _list(List<ReadarrUnifiedSearchResult>? data) {
    if ((data?.length ?? 0) == 0)
      return ZagListView(
        controller: scrollController,
        children: [ZagMessage(text: 'readarr.NoResultsFound'.tr())],
      );
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: data!.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final isAlreadyAdded = item.type == ReadarrSearchResultType.author
            ? _availableAuthorIDs.contains(item.foreignAuthorId)
            : _availableBookIDs.contains(item.foreignBookId);
        return ReadarrUnifiedSearchResultTile(
          data: item,
          alreadyAdded: isAlreadyAdded,
        );
      },
    );
  }
}
