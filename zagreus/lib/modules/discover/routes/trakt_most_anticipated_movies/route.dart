import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/discover/core/trakt_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, Map<String, dynamic>?> _ratingsCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData?.isNotEmpty == true) {
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
      final movies = await TraktApi.getAnticipatedMovies(page: 1, limit: 40);
      final radarrState = context.read<RadarrState>();
      List<RadarrMovie>? radarrMovies;
      if (radarrState.enabled) {
        if (radarrState.movies == null) {
          radarrState.fetchMovies();
        }
        if (radarrState.movies != null) {
          radarrMovies = await radarrState.movies!;
        }
      }

      for (final movie in movies) {
        final tmdbId = movie['tmdbId'] as int?;
        if (tmdbId != null) {
          final details = await TMDBApi.getMovieDetails(tmdbId);
          if (details != null) {
            movie['poster'] = TMDBApi.getImageUrl(
              details['poster_path'],
              size: 'w500',
            );
            movie['backdrop'] = TMDBApi.getImageUrl(details['backdrop_path']);
            movie['overview'] ??= details['overview'];
            movie['releaseDate'] ??= details['release_date'];
          }
        }

        await _ensureTraktRating(movie);
        movie['inLibrary'] = false;
        if (radarrMovies != null && radarrMovies.isNotEmpty) {
          for (final radarrMovie in radarrMovies) {
            final matchesTmdb = tmdbId != null && radarrMovie.tmdbId == tmdbId;
            final matchesImdb = radarrMovie.imdbId != null &&
                radarrMovie.imdbId == (movie['imdbId'] as String?);
            if (matchesTmdb || matchesImdb) {
              movie['inLibrary'] = true;
              movie['serviceItemId'] = radarrMovie.id;
              break;
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
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
      title: 'Most Anticipated Movies',
      actions: [
        IconButton(
          icon: const Icon(ZagIcons.REFRESH),
          onPressed: _loadAnticipatedMovies,
          tooltip: 'Refresh',
        ),
      ],
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

    final savedColumns = ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
    final usesThreeColumns = savedColumns == 3;
    final horizontalPadding = usesThreeColumns ? 20.0 : 16.0;
    final gridSpacing = usesThreeColumns ? 16.0 : 12.0;

    return RefreshIndicator(
      onRefresh: _loadAnticipatedMovies,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: savedColumns,
          childAspectRatio: 0.58,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
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

    return GestureDetector(
      onTap: () => _handleMovieTap(movie),
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
              // Gradient overlay
              if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
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
                      stops: const [0.0, 0.6, 1.0],
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
              // Title at bottom
              if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: AutoSizeText(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
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
        message: 'Connect Radarr to manage movies from Discover.',
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
}
