import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMissingRoute extends StatefulWidget {
  const RadarrMissingRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMissingRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  // Multi-select mode
  bool _isMultiSelectMode = false;
  Set<int> _selectedMovieIds = {};

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _isMultiSelectMode ? _multiSelectAppBar() : null,
      body: _body,
    );
  }

  PreferredSizeWidget _multiSelectAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isMultiSelectMode = false;
            _selectedMovieIds.clear();
          });
        },
      ),
      title: Text('${_selectedMovieIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: _toggleSelectAll,
          tooltip: 'Select All',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _selectedMovieIds.isEmpty ? null : _searchForSelectedMovies,
          tooltip: 'Search Selected',
        ),
      ],
    );
  }

  void toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedMovieIds.clear();
      }
    });
  }

  void _toggleSelectAll() async {
    final movies = await context.read<RadarrState>().missing;
    if (movies == null) return;

    setState(() {
      if (_selectedMovieIds.length == movies.length) {
        _selectedMovieIds.clear();
      } else {
        _selectedMovieIds = Set.from(movies.map((m) => m.id!));
      }
    });
  }

  Future<void> _refresh() async {
    RadarrState _state = context.read<RadarrState>();
    _state.fetchMovies();
    _state.fetchQualityProfiles();
    await Future.wait([
      _state.missing!,
      _state.qualityProfiles!,
    ]);
  }

  Widget get _body => ZagRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: Future.wait([
            context.watch<RadarrState>().missing!,
            context.watch<RadarrState>().qualityProfiles!,
          ]),
          builder: (context, AsyncSnapshot<List<Object>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting)
                ZagLogger().error(
                  'Unable to fetch Radarr upcoming',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              return ZagMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData)
              return _list(snapshot.data![0] as List<RadarrMovie>,
                  snapshot.data![1] as List<RadarrQualityProfile>);
            return const ZagLoader();
          },
        ),
      );

  Widget _list(
    List<RadarrMovie> movies,
    List<RadarrQualityProfile> qualityProfiles,
  ) {
    if (movies.isEmpty) {
      return ZagMessage(
        text: 'radarr.NoMoviesFound'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }
    return ZagListViewBuilder(
      controller: RadarrNavigationBar.scrollControllers[2],
      itemCount: movies.length,
      itemExtent: RadarrMissingTile.itemExtent,
      itemBuilder: (context, index) => RadarrMissingTile(
        movie: movies[index],
        profile: qualityProfiles.firstWhereOrNull(
            (element) => element.id == movies[index].qualityProfileId),
        isMultiSelectMode: _isMultiSelectMode,
        isSelected: _selectedMovieIds.contains(movies[index].id),
        onToggleSelection: () => _toggleSelection(movies[index].id!),
      ),
    );
  }

  void _toggleSelection(int movieId) {
    setState(() {
      if (_selectedMovieIds.contains(movieId)) {
        _selectedMovieIds.remove(movieId);
      } else {
        _selectedMovieIds.add(movieId);
      }
    });
  }

  Future<void> _searchForSelectedMovies() async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: 'Radarr Not Available',
        message: 'Radarr is not enabled or configured',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    showZagSnackBar(
      title: 'Searching',
      message: 'Searching for ${_selectedMovieIds.length} missing movies...',
      type: ZagSnackbarType.INFO,
    );

    try {
      // Trigger search for all selected movies
      await radarrState.api!.command.moviesSearch(
        movieIds: _selectedMovieIds.toList(),
      );

      showZagSnackBar(
        title: 'Search Started',
        message: 'Search started for ${_selectedMovieIds.length} movies',
        type: ZagSnackbarType.SUCCESS,
      );

      // Exit multi-select mode
      setState(() {
        _isMultiSelectMode = false;
        _selectedMovieIds.clear();
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to search for movies', e, stack);
      showZagSnackBar(
        title: 'Search Failed',
        message: 'Failed to start search: $e',
        type: ZagSnackbarType.ERROR,
      );
    }
  }
}
