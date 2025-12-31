import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogue extends StatefulWidget {
  static const ROUTE_NAME = '/readarr/catalogue';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const ReadarrCatalogue({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<ReadarrCatalogue> createState() => _State();
}

class _State extends State<ReadarrCatalogue>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<ReadarrCatalogueData>>? _future;
  List<ReadarrCatalogueData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    if (mounted) setState(() => _results = []);
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    if (mounted) {
      setState(() {
        _future = _api.getAllAuthors();
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
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: widget.refreshIndicatorKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<ReadarrCatalogueData>> snapshot) {
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
        text: 'No Authors Found',
        buttonText: 'Refresh',
        onTap: widget.refreshIndicatorKey.currentState?.show,
      );
    return Consumer<ReadarrState>(
      builder: (context, model, _) {
        List<ReadarrCatalogueData> _filtered = _filter(_results!, model);
        _sort(_filtered, model);
        return Scrollbar(
          child: ListView.builder(
            controller: ReadarrNavigationBar.scrollControllers[0],
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              return ReadarrCatalogueTile(
                data: _filtered[index],
              );
            },
          ),
        );
      },
    );
  }

  List<ReadarrCatalogueData> _filter(
      List<ReadarrCatalogueData> authors, ReadarrState model) {
    if (model.searchCatalogueFilter.isEmpty && !model.hideUnmonitoredAuthors)
      return authors;
    return authors.where((author) {
      // Filter by search query
      if (model.searchCatalogueFilter.isNotEmpty) {
        String query = model.searchCatalogueFilter.toLowerCase();
        if (!author.title.toLowerCase().contains(query)) return false;
      }
      // Filter by monitored status
      if (model.hideUnmonitoredAuthors) {
        if (author.monitored == null || !author.monitored!) return false;
      }
      return true;
    }).toList();
  }

  void _sort(List<ReadarrCatalogueData> authors, ReadarrState model) {
    ReadarrCatalogueSorting _sortType = model.sortCatalogueType;
    bool _ascending = model.sortCatalogueAscending;
    authors.sort((a, b) {
      switch (_sortType) {
        case ReadarrCatalogueSorting.alphabetical:
          return _ascending
              ? a.sortTitle.toLowerCase().compareTo(b.sortTitle.toLowerCase())
              : b.sortTitle.toLowerCase().compareTo(a.sortTitle.toLowerCase());
        case ReadarrCatalogueSorting.quality:
          return _ascending
              ? (a.quality ?? '').compareTo(b.quality ?? '')
              : (b.quality ?? '').compareTo(a.quality ?? '');
        case ReadarrCatalogueSorting.metadata:
          return _ascending
              ? (a.metadata ?? '').compareTo(b.metadata ?? '')
              : (b.metadata ?? '').compareTo(a.metadata ?? '');
        case ReadarrCatalogueSorting.books:
          {
            int aBooks = a.statistics['bookCount'] ?? 0;
            int bBooks = b.statistics['bookCount'] ?? 0;
            return _ascending ? aBooks.compareTo(bBooks) : bBooks.compareTo(aBooks);
          }
        case ReadarrCatalogueSorting.size:
          return _ascending
              ? a.sizeOnDisk.compareTo(b.sizeOnDisk)
              : b.sizeOnDisk.compareTo(a.sizeOnDisk);
        case ReadarrCatalogueSorting.type:
          return _ascending
              ? a.authorType.compareTo(b.authorType)
              : b.authorType.compareTo(a.authorType);
        case ReadarrCatalogueSorting.dateAdded:
          {
            if (a.dateAddedObject == null && b.dateAddedObject == null)
              return 0;
            if (a.dateAddedObject == null) return 1;
            if (b.dateAddedObject == null) return -1;
            return _ascending
                ? a.dateAddedObject!.compareTo(b.dateAddedObject!)
                : b.dateAddedObject!.compareTo(a.dateAddedObject!);
          }
      }
    });
  }
}
