import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class AuthorBookReleasesRoute extends StatefulWidget {
  final int bookId;

  const AuthorBookReleasesRoute({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  State<AuthorBookReleasesRoute> createState() => _State();
}

class _State extends State<AuthorBookReleasesRoute>
    with ZagScrollControllerMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<ReadarrReleaseData>>? _future;
  List<ReadarrReleaseData>? _results = [];

  @override
  Future<void> loadCallback() async {
    if (mounted) setState(() => _results = []);
    final _api = ReadarrAPI.from(ZagProfile.current);
    setState(() {
      _future = _api.getReleases(widget.bookId);
    });
    // Clear any previous filters
    Future.microtask(
        () => context.read<ReadarrState>().searchReleasesFilter = '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookId <= 0) {
      return InvalidRoutePage(
        title: 'Releases',
        message: 'Book Not Found',
      );
    }
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      appBar: _appBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Releases',
      scrollControllers: [scrollController],
      bottom: ReadarrReleasesSearchBar(scrollController: scrollController),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<ReadarrReleaseData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  if (snapshot.connectionState != ConnectionState.waiting) {
                    ZagLogger().error(
                      'Unable to fetch Readarr releases (${widget.bookId})',
                      snapshot.error,
                      snapshot.stackTrace,
                    );
                  }
                  return ZagMessage.error(
                      onTap: _refreshKey.currentState!.show);
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
    if ((_results?.length ?? 0) == 0) {
      return ZagMessage(
        text: 'No Releases Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState?.show,
      );
    }
    return Consumer<ReadarrState>(
      builder: (context, state, _) {
        List<ReadarrReleaseData>? filtered =
            _filterAndSort(_results, state.searchReleasesFilter);
        if ((filtered?.length ?? 0) == 0) {
          return ZagListView(
            controller: scrollController,
            children: [
              ZagMessage.inList(text: 'No Releases Found'),
            ],
          );
        }
        return ZagListViewBuilder(
          controller: scrollController,
          itemCount: filtered!.length,
          itemBuilder: (context, index) =>
              ReadarrReleasesTile(release: filtered[index]),
        );
      },
    );
  }

  List<ReadarrReleaseData>? _filterAndSort(
      List<ReadarrReleaseData>? releases, String query) {
    if ((releases?.length ?? 0) == 0) return releases;
    ReadarrReleasesSorting sorting =
        context.read<ReadarrState>().sortReleasesType;
    bool shouldHide = context.read<ReadarrState>().hideRejectedReleases;
    bool ascending = context.read<ReadarrState>().sortReleasesAscending;
    // Filter
    List<ReadarrReleaseData> filtered = releases!.where((release) {
      if (shouldHide && !release.approved) return false;
      if (query.isNotEmpty) {
        return release.title.toLowerCase().contains(query.toLowerCase());
      }
      return true;
    }).toList();
    filtered = sorting.sort(filtered, ascending);
    return filtered;
  }
}
