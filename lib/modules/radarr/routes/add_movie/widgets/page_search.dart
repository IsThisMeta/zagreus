import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrAddMovieSearchPage extends StatefulWidget {
  final bool autofocusSearchBar;

  const RadarrAddMovieSearchPage({
    Key? key,
    required this.autofocusSearchBar,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrAddMovieSearchPage>
    with AutomaticKeepAliveClientMixin, ZagLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    if (context.read<RadarrAddMovieState>().searchQuery.isNotEmpty) {
      final query = context.read<RadarrAddMovieState>().searchQuery;
      context.read<RadarrAddMovieState>().fetchLookup(context);
      
      // Wait for lookup results
      final lookupResults = await context.read<RadarrAddMovieState>().lookup;
      await context.read<RadarrAddMovieState>().exclusions;
      
      // If searching by TMDB ID and found exactly one result, auto-navigate
      if (query.startsWith('tmdb:') && lookupResults != null && lookupResults.length == 1) {
        final movie = lookupResults.first;
        
        // Check if movie exists in library
        final movies = await context.read<RadarrState>().movies;
        final existingMovie = movies?.firstWhere(
          (m) => m.id == movie.id,
          orElse: () => RadarrMovie(),
        );
        
        if (existingMovie?.id != null) {
          // Movie exists, go to details
          RadarrRoutes.MOVIE.go(params: {
            'movie': existingMovie!.id!.toString(),
          });
        } else {
          // Movie doesn't exist, go to add movie details
          RadarrRoutes.ADD_MOVIE_DETAILS.go(
            extra: movie,
            queryParams: {'isDiscovery': 'false'},
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar.empty(
      child: RadarrAddMovieSearchSearchBar(
        query: context.read<RadarrAddMovieState>().searchQuery,
        autofocus: widget.autofocusSearchBar,
        scrollController: RadarrAddMovieNavigationBar.scrollControllers[0],
      ),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }

  Widget _body() {
    return Selector<RadarrState, Future<List<RadarrMovie>>?>(
      selector: (_, state) => state.movies,
      builder: (context, movies, _) => Selector<RadarrAddMovieState,
          Tuple2<Future<List<RadarrMovie>>?, Future<List<RadarrExclusion>>?>>(
        selector: (_, state) => Tuple2(state.lookup, state.exclusions),
        builder: (context, tuple, _) {
          if (tuple.item1 == null) return Container();
          return _builder(movies, tuple.item1, tuple.item2);
        },
      ),
    );
  }

  Widget _builder(
      Future<List<RadarrMovie>>? movies,
      Future<List<RadarrMovie>>? lookup,
      Future<List<RadarrExclusion>>? exclusions) {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: Future.wait([movies!, lookup!, exclusions!]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Radarr movie lookup',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData)
            return _list(
                snapshot.data![0], snapshot.data![1], snapshot.data![2]);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(
    List<RadarrMovie> movies,
    List<RadarrMovie> results,
    List<RadarrExclusion> exclusions,
  ) {
    if (results.isEmpty)
      return ZagListView(
        controller: RadarrAddMovieNavigationBar.scrollControllers[0],
        children: [
          ZagMessage.inList(text: 'radarr.NoResultsFound'.tr()),
        ],
      );
    return ZagListViewBuilder(
      controller: RadarrAddMovieNavigationBar.scrollControllers[0],
      itemCount: results.length,
      itemBuilder: (context, index) {
        RadarrExclusion? exclusion = exclusions.firstWhereOrNull(
            (exclusion) => exclusion.tmdbId == results[index].tmdbId);
        RadarrMovie? movie = movies
            .firstWhereOrNull((movie) => (movie.id ?? -1) == results[index].id);
        return RadarrAddMovieSearchResultTile(
          movie: results[index],
          exists: movie != null,
          isExcluded: exclusion != null,
        );
      },
    );
  }
}
