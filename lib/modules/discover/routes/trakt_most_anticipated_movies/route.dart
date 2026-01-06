import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/discover/core/trakt_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/system/platform.dart';

class TraktMostAnticipatedMoviesRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TraktMostAnticipatedMoviesRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TraktMostAnticipatedMoviesRoute> createState() => _State();
}

class _State extends State<TraktMostAnticipatedMoviesRoute>
    with ZagScrollControllerMixin {
  bool get _showTitles => ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const int _pageSize = 40;

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  int _totalPages = 1;
  final Map<String, Map<String, dynamic>?> _ratingsCache = {};

  @override
  void initState() {
    super.initState();
    // _loadSavedSettings(); // Not needed for simple movie list

    final cached =
        DiscoverSessionCache().get('TraktMostAnticipatedMoviesRoute');
    if (cached != null) {
      _movies = List<Map<String, dynamic>>.from(cached.items);
      _currentPage = cached.currentPage;
      _totalPages = cached.extra?['totalPages'] ?? 1;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
    } else if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _movies = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadAnticipatedMovies(silent: true);
        }
      });
    } else {
      _loadAnticipatedMovies();
    }

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'TraktMostAnticipatedMoviesRoute',
        DiscoverRouteState(
          items: _movies,
          currentPage: _currentPage,
          scrollOffset:
              scrollController.hasClients ? scrollController.offset : 0.0,
          hasMorePages: _currentPage < _totalPages,
          extra: {'totalPages': _totalPages},
        ),
      );
    }
    scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients || _isLoadingMore || !_hasMorePages) {
      return;
    }

    final threshold = scrollController.position.maxScrollExtent -
        scrollController.position.viewportDimension;
    if (scrollController.position.pixels >= threshold) {
      _loadMoreMovies();
    }
  }

  Future<void> _loadAnticipatedMovies({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      final movies = await _fetchAnticipatedMoviesPage(page: 1);

      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
        _currentPage = 1;
        _hasMorePages = movies.length >= _pageSize;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load anticipated movies', error, stack);
      if (!mounted) return;
      if (silent && _movies.isNotEmpty) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final movies = await _fetchAnticipatedMoviesPage(page: nextPage);

      if (!mounted) return;

      final existingKeys =
          _movies.map(_movieIdentity).whereType<String>().toSet();
      final newMovies = movies.where((movie) {
        final key = _movieIdentity(movie);
        if (key == null) return true;
        if (existingKeys.contains(key)) {
          return false;
        }
        existingKeys.add(key);
        return true;
      }).toList();

      setState(() {
        _movies.addAll(newMovies);
        _currentPage = nextPage;
        _hasMorePages = movies.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load more anticipated movies', error, stack);
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _hasMorePages = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAnticipatedMoviesPage({
    required int page,
  }) async {
    final movies =
        await TraktApi.getAnticipatedMovies(page: page, limit: _pageSize);
    await _hydrateMoviesWithTmdb(movies);
    await _ensureMovieRatings(movies);
    await _markMoviesInRadarr(movies);
    return movies;
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'discover.section.most_anticipated_movies'.tr(),
      actions: [],
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(child: ZagLoader());
    }

    if (_error != null && _movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading anticipated movies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnticipatedMovies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Text(
          'No anticipated movies found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final savedColumns = _getColumnsForDevice(context);
    final usesThreeColumns = savedColumns == 3;
    final horizontalPadding = usesThreeColumns ? 20.0 : 16.0;

    // Adjust spacing based on column count
    final double gridSpacing;
    if (savedColumns <= 3) {
      gridSpacing = 16.0;
    } else if (savedColumns <= 5) {
      gridSpacing = 12.0;
    } else {
      gridSpacing = 10.0;
    }
    // Check if titles should be beneath posters
    final showTitles = _showTitles;
    final titlesBeneath = showTitles;

    // Adjust aspect ratio when titles are beneath
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;



    return RefreshIndicator(
      onRefresh: _loadAnticipatedMovies,
      child: GridView.builder(
        cacheExtent: 2000.0,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: savedColumns,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
        ),
        itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _movies.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _movieTile(_movies[index]);
        },
      ),
    );
  }

  Widget _movieTile(Map<String, dynamic> movie) {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final double rating = (movie['rating'] ?? 0.0).toDouble();
    final String title = movie['title'] ?? 'Unknown';
    final String? releaseDate = movie['releaseDate'] as String?;
    final String year = releaseDate != null && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : '';
    final showTitles = _showTitles;
    final titlesBeneath = showTitles;

    return GestureDetector(
      onTap: () => _handleMovieTap(movie),
      onLongPress: () => _showMoviePreview(movie),
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(movie, inLibrary, rating, title)
          : _buildTileWithOverlayTitle(movie, inLibrary, rating, title),
    );
  }

  Widget _buildTileWithTitleBeneath(
    Map<String, dynamic> movie,
    bool inLibrary,
    double rating,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade900,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPoster(movie),
                  // Library indicator dot - top right
                  if (inLibrary)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: ZagColours.orange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Rating badge - top left
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(rating),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTileWithOverlayTitle(
    Map<String, dynamic> movie,
    bool inLibrary,
    double rating,
    String title,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPoster(movie),
            // Gradient overlay
            if (_showTitles)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            // Library indicator dot - top right
            if (inLibrary)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: ZagColours.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            // Rating badge - top left
            if (rating > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: _ratingColor(rating),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Title at bottom
            if (_showTitles)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: AutoSizeText(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getTitleFontSize(context),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  minFontSize: 11,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(Map<String, dynamic> movie) {
    final String? posterUrl = movie['poster'] as String?;
    if (posterUrl != null && posterUrl.isNotEmpty) {
      return Image.network(
        posterUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _posterFallback(movie),
      );
    }
    return _posterFallback(movie);
  }

  Widget _posterFallback(Map<String, dynamic> movie) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_filter_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              movie['title'] ?? 'Unknown',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _ratingColor(double rating) {
    final monochrome = ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.read();
    if (monochrome) {
      return Colors.white;
    }

    if (rating >= 8.0) {
      return const Color(0xFF35C5F4); // Blue for high ratings
    } else if (rating >= 6.0) {
      // Gradient from yellow (6.0) to green (8.0)
      final progress = (rating - 6.0) / 2.0;
      return Color.lerp(
        const Color(0xFFFEC333), // Yellow
        const Color(0xFF4CAF50), // Green
        progress,
      )!;
    } else if (rating >= 5.0) {
      return const Color(0xFFFFA726); // Orange
    } else {
      return const Color(0xFFEF5350); // Red for low ratings
    }
  }

  Future<void> _handleMovieTap(Map<String, dynamic> movie) async {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final int? serviceItemId = movie['serviceItemId'] as int?;
    final int? tmdbId = movie['tmdbId'] as int?;
    final String? title = movie['title'] as String?;

    if (inLibrary && serviceItemId != null) {
      RadarrRoutes.MOVIE.go(
        params: {
          'movie': serviceItemId.toString(),
        },
      );
      return;
    }

    if (tmdbId != null) {
      await _openMovieInRadarr(
        tmdbId: tmdbId,
        title: title,
      );
      return;
    }

    showZagSnackBar(
      title: title ?? 'Radarr',
      message: 'Missing TMDB identifier for this title.',
      type: ZagSnackbarType.ERROR,
    );
  }

  Future<void> _openMovieInRadarr({
    required int tmdbId,
    String? title,
  }) async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: title ?? 'Radarr',
        message: 'Connect Radarr to manage movies from Dashboard.',
        type: ZagSnackbarType.INFO,
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderShown = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: ZagLoader()),
    );
    loaderShown = true;

    try {
      final results = await radarrState.api!.movieLookup.get(
        term: 'tmdb:$tmdbId',
      );

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Movie',
          message: 'Could not find TMDB ID $tmdbId in Radarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final radarrMovie = results.first;

      if (radarrMovie.id != null) {
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': radarrMovie.id!.toString(),
          },
        );
        return;
      }

      RadarrRoutes.ADD_MOVIE_DETAILS.go(
        extra: radarrMovie,
        queryParams: {'isDiscovery': 'true'},
      );
    } catch (error, stack) {
      dismissLoader();
      if (!mounted) return;
      ZagLogger().error('Failed to open Radarr add movie flow', error, stack);
      showZagSnackBar(
        title: title ?? 'Movie',
        message: 'Something went wrong talking to Radarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _ensureTraktRating(Map<String, dynamic> movie) async {
    final currentRating = (movie['rating'] as num?)?.toDouble();
    if (currentRating != null && currentRating > 0) {
      movie['rating'] = currentRating;
      return;
    }

    final slug = movie['slug'] as String?;
    final traktId = movie['traktId'];
    final imdbId = movie['imdbId'] as String?;
    final identifier = slug ?? traktId?.toString() ?? imdbId;
    if (identifier == null || identifier.isEmpty) {
      movie['rating'] = currentRating ?? 0.0;
      return;
    }

    final cacheKey = 'movie:$identifier';
    Map<String, dynamic>? ratingData = _ratingsCache[cacheKey];
    if (ratingData == null) {
      ratingData = await TraktApi.getMovieRatings(identifier);
      if (ratingData != null) {
        _ratingsCache[cacheKey] = ratingData;
      }
    }

    if (ratingData != null) {
      final rating = (ratingData['rating'] as num?)?.toDouble();
      final votes = (ratingData['votes'] as num?)?.toInt();
      if (rating != null) {
        movie['rating'] = rating;
      }
      if (votes != null) {
        movie['votes'] = votes;
      }
    }

    movie['rating'] = (movie['rating'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> _hydrateMoviesWithTmdb(List<Map<String, dynamic>> movies) async {
    for (final movie in movies) {
      final tmdbId = movie['tmdbId'] as int?;
      if (tmdbId == null) continue;

      final details = await TMDBApi.getMovieDetails(tmdbId);
      if (details == null) continue;

      movie['poster'] = TMDBApi.getImageUrl(
        details['poster_path'],
        size: 'w342',
      );
      movie['backdrop'] = TMDBApi.getImageUrl(details['backdrop_path']);
      movie['overview'] ??= details['overview'];
      movie['releaseDate'] ??= details['release_date'];
    }
  }

  Future<void> _ensureMovieRatings(List<Map<String, dynamic>> movies) async {
    for (final movie in movies) {
      await _ensureTraktRating(movie);
    }
  }

  Future<void> _markMoviesInRadarr(List<Map<String, dynamic>> movies) async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled) {
      for (final movie in movies) {
        movie['inLibrary'] = false;
      }
      return;
    }

    if (radarrState.movies == null) {
      radarrState.fetchMovies();
    }

    final radarrMoviesFuture = radarrState.movies;
    if (radarrMoviesFuture == null) {
      for (final movie in movies) {
        movie['inLibrary'] = false;
      }
      return;
    }

    final radarrMovies = await radarrMoviesFuture;
    for (final movie in movies) {
      final tmdbId = movie['tmdbId'] as int?;
      final imdbId = movie['imdbId'] as String?;

      movie['inLibrary'] = false;
      if (radarrMovies.isEmpty) continue;

      for (final radarrMovie in radarrMovies) {
        final matchesTmdb = tmdbId != null && radarrMovie.tmdbId == tmdbId;
        final matchesImdb = imdbId != null && radarrMovie.imdbId == imdbId;

        if (matchesTmdb || matchesImdb) {
          movie['inLibrary'] = true;
          movie['serviceItemId'] = radarrMovie.id;
          break;
        }
      }
    }
  }

  String? _movieIdentity(Map<String, dynamic> movie) {
    final dynamic traktId = movie['traktId'];
    final dynamic tmdbId = movie['tmdbId'];
    final dynamic id = movie['id'];
    final dynamic identity = traktId ?? tmdbId ?? id;
    return identity?.toString();
  }

  double _getTitleFontSize(BuildContext context) {
    final savedColumns = _getColumnsForDevice(context);
    if (savedColumns >= 6) return 12.0;
    if (savedColumns == 5) return 13.0;
    return savedColumns == 2 ? 16.0 : (savedColumns == 4 ? 16.0 : 14.0);
  }

  int _getColumnsForDevice(BuildContext context) {
    if (ZagPlatform.isTablet(context)) {
      return ZagreusDatabase.DISCOVER_IPAD_COLUMNS_PER_ROW.read() ?? 4;
    }
    return ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
  }

  // Radarr quick add settings
  int? _radarrQualityProfileId;
  String? _radarrQualityProfileName;
  String? _radarrRootFolder;

  /// Show movie preview with Add button on long press (for non-library items)
  /// or Radarr actions dialog for items already in library
  Future<void> _showMoviePreview(Map<String, dynamic> movie) async {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final tmdbId = movie['tmdbId'] as int?;

    if (tmdbId == null) return;

    // If in library, show manage dialog instead
    if (inLibrary) {
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final movies = await radarrState.movies!;
        final radarrMovie = movies.firstWhere(
          (m) => m.tmdbId == tmdbId,
          orElse: () => RadarrMovie(),
        );
        if (radarrMovie.id != null && radarrMovie.id! > 0) {
          await _showRadarrMovieActions(radarrMovie);
          return;
        }
      }
      return;
    }

    final title = movie['title'] as String? ?? 'Movie';
    final overview = movie['overview'] as String? ?? 'No overview available.';

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      title,
      overview,
      onAdd: () => _openMovieInRadarr(tmdbId: tmdbId, title: title),
      alignLeft: true,
      rootFolderValue: _radarrRootFolder,
      qualityProfileValue: _radarrQualityProfileName,
      getRootFolders: _getRadarrRootFolders,
      getQualityProfiles: _getRadarrQualityProfiles,
      onRootFolderChanged: _onRadarrRootFolderChanged,
      onQualityProfileChanged: _onRadarrQualityProfileChanged,
    );
  }

  Future<void> _showRadarrMovieActions(RadarrMovie movie) async {
    if (!mounted || movie.id == null || movie.id == 0) return;
    try {
      HapticFeedback.lightImpact();
      final result = await RadarrDialogs().movieSettings(context, movie);
      if (!mounted) return;
      if (result.item1 && result.item2 != null) {
        result.item2!.execute(context, movie);
      }
    } catch (error, stack) {
      ZagLogger().error(
          'Failed to open Radarr actions for ${movie.title}', error, stack);
      showZagSnackBar(
        title: movie.title ?? 'Radarr',
        message: 'Could not load movie actions.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<List<String>> _getRadarrRootFolders() async {
    final radarrState = context.read<RadarrState>();
    final folders = await radarrState.rootFolders;
    return folders
            ?.map((f) => f.path ?? '')
            .where((p) => p.isNotEmpty)
            .toList() ??
        [];
  }

  Future<List<({int id, String name})>> _getRadarrQualityProfiles() async {
    final radarrState = context.read<RadarrState>();
    final profiles = await radarrState.api!.qualityProfile.getAll();
    return profiles
        .map((p) => (id: p.id ?? 0, name: p.name ?? 'Unknown'))
        .toList();
  }

  void _onRadarrRootFolderChanged(String path) {
    setState(() => _radarrRootFolder = path);
    ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(path);
  }

  void _onRadarrQualityProfileChanged(int id, String name) {
    setState(() {
      _radarrQualityProfileId = id;
      _radarrQualityProfileName = name;
    });
    ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(id);
    ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(name);
  }
}
