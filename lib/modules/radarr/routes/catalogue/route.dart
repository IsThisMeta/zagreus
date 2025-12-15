import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/types/list_view_option.dart';

class RadarrCatalogueRoute extends StatefulWidget {
  const RadarrCatalogueRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrCatalogueRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    RadarrState _state = context.read<RadarrState>();
    _state.fetchMovies();
    _state.fetchQualityProfiles();
    _state.fetchTags();
    await Future.wait([
      _state.movies!,
      _state.qualityProfiles!,
      _state.tags!,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      appBar: _appBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar.empty(
      child: RadarrCatalogueSearchBar(
        scrollController: RadarrNavigationBar.scrollControllers[0],
      ),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: Selector<
              RadarrState,
              Tuple2<Future<List<RadarrMovie>>?,
                  Future<List<RadarrQualityProfile>>?>>(
          selector: (_, state) => Tuple2(
                state.movies,
                state.qualityProfiles,
              ),
          builder: (context, tuple, _) {
            return FutureBuilder(
              future: Future.wait([
                tuple.item1!,
                tuple.item2!,
              ]),
              builder: (context, AsyncSnapshot<List<Object>> snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.connectionState != ConnectionState.waiting) {
                    ZagLogger().error(
                      'Unable to fetch Radarr movies',
                      snapshot.error,
                      snapshot.stackTrace,
                    );
                  }
                  return ZagMessage.error(
                    onTap: _refreshKey.currentState!.show,
                  );
                }
                if (snapshot.hasData)
                  return _movieList(
                    snapshot.data![0] as List<RadarrMovie>,
                    snapshot.data![1] as List<RadarrQualityProfile>,
                  );
                return const ZagLoader();
              },
            );
          }),
    );
  }

  List<RadarrMovie> _filterAndSort(
    List<RadarrMovie> movies,
    String query,
  ) {
    if (movies.isEmpty) return movies;
    RadarrMoviesSorting sorting = context.watch<RadarrState>().moviesSortType;
    RadarrMoviesFilter filter = context.watch<RadarrState>().moviesFilterType;
    bool ascending = context.watch<RadarrState>().moviesSortAscending;
    // Filter
    List<RadarrMovie> filtered = movies.where((movie) {
      if (query.isNotEmpty && movie.id != null)
        return movie.title!.toLowerCase().contains(query.toLowerCase());
      return movie.id != null;
    }).toList();
    filtered = filter.filter(filtered);
    // Sort
    filtered = sorting.sort(filtered, ascending);
    return filtered;
  }

  Widget _movieList(
    List<RadarrMovie> movies,
    List<RadarrQualityProfile> qualityProfiles,
  ) {
    if (movies.isEmpty)
      return ZagMessage(
        text: 'radarr.NoMoviesFound'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    return Selector<RadarrState, String>(
      selector: (_, state) => state.moviesSearchQuery,
      builder: (context, query, _) {
        List<RadarrMovie> _filtered = _filterAndSort(movies, query);
        if (_filtered.isEmpty)
          return ZagListView(
            controller: RadarrNavigationBar.scrollControllers[0],
            children: [
              ZagMessage.inList(text: 'radarr.NoMoviesFound'.tr()),
              if (query.isNotEmpty)
                ZagButtonContainer(
                  children: [
                    ZagButton.text(
                      icon: null,
                      text: query.length > 20
                          ? 'radarr.SearchFor'.tr(args: [
                              '"${query.substring(0, min(20, query.length))}${ZagUI.TEXT_ELLIPSIS}"'
                            ])
                          : 'radarr.SearchFor'.tr(args: ['"$query"']),
                      backgroundColor: ZagColours.currentAccent,
                      onTap: () => RadarrRoutes.ADD_MOVIE.go(queryParams: {
                        'query': query,
                      }),
                    ),
                  ],
                ),
            ],
          );
        switch (context.read<RadarrState>().moviesViewType) {
          case ZagListViewOption.BLOCK_VIEW:
            return _blockView(_filtered, qualityProfiles);
          case ZagListViewOption.GRID_VIEW:
            return _gridView(_filtered, qualityProfiles);
          default:
            throw Exception('Invalid moviesViewType');
        }
      },
    );
  }

  Widget _blockView(
    List<RadarrMovie> movies,
    List<RadarrQualityProfile> qualityProfiles,
  ) {
    return ZagListViewBuilder(
      controller: RadarrNavigationBar.scrollControllers[0],
      itemCount: movies.length,
      itemExtent: RadarrCatalogueTile.itemExtent,
      itemBuilder: (context, index) => RadarrCatalogueTile(
        movie: movies[index],
        profile: qualityProfiles.firstWhereOrNull(
          (element) => element.id == movies[index].qualityProfileId,
        ),
      ),
    );
  }

  Widget _gridView(
    List<RadarrMovie> movies,
    List<RadarrQualityProfile> qualityProfiles,
  ) {
    return ZagGridViewBuilder(
      controller: RadarrNavigationBar.scrollControllers[0],
      sliverGridDelegate: ZagGridBlock.getMaxCrossAxisExtent(),
      itemCount: movies.length,
      itemBuilder: (context, index) => RadarrCatalogueTile.grid(
        movie: movies[index],
        profile: qualityProfiles.firstWhereOrNull(
          (element) => element.id == movies[index].qualityProfileId,
        ),
      ),
    );
  }
}
