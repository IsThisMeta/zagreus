import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/system/platform.dart';

class StudioDiscoverRoute extends StatefulWidget {
  final int studioId;
  final String studioName;
  final String? studioLogo;

  const StudioDiscoverRoute({
    Key? key,
    required this.studioId,
    required this.studioName,
    this.studioLogo,
  }) : super(key: key);

  @override
  State<StudioDiscoverRoute> createState() => _State();
}

class _State extends State<StudioDiscoverRoute> with ZagScrollControllerMixin {
  bool get _showTitles => ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  int get _titleMaxLines => 3;

  double _getTitleFontSize(BuildContext context) {
    final savedColumns = _getColumnsForDevice(context);
    if (savedColumns >= 6) return 12.0;
    if (savedColumns == 5) return 13.0;
    return savedColumns == 2 ? 16.0 : (savedColumns == 4 ? 16.0 : 14.0);
  }

  @override
  void initState() {
    super.initState();

    final cacheKey = 'StudioDiscoverRoute_${widget.studioId}';
    final cached = DiscoverSessionCache().get(cacheKey);
    if (cached != null) {
      _movies = List<Map<String, dynamic>>.from(cached.items);
      _currentPage = cached.currentPage;
      _hasMorePages = cached.hasMorePages;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
    } else {
      _loadMovies();
    }

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'StudioDiscoverRoute_${widget.studioId}',
        DiscoverRouteState(
          items: _movies,
          currentPage: _currentPage,
          scrollOffset:
              scrollController.hasClients ? scrollController.offset : 0.0,
          hasMorePages: _hasMorePages,
        ),
      );
    }
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent -
            scrollController.position.viewportDimension) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMoreMovies();
      }
    }
  }

  Color _ratingColor(double rating) {
    final monochrome = ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.read();
    if (monochrome) {
      return Colors.white;
    }

    if (rating >= 8.0) {
      return const Color(0xFF64B5F6);
    } else if (rating >= 6.0) {
      final progress = (rating - 6.0) / 2.0;
      final hue = 0.15 + progress * 0.15;
      return HSVColor.fromAHSV(1.0, hue * 360, 0.8, 0.9).toColor();
    } else if (rating >= 5.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> _loadMovies({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final movies = await TMDBApi.getMoviesByStudio(
        widget.studioId,
        page: 1,
        region: region,
      );

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        try {
          final radarrMovies = await radarrState.movies!;

          for (final movie in movies) {
            final tmdbId = movie['tmdbId'] as int?;
            final title = movie['title'] as String;

            final inLibrary = radarrMovies.any((radarrMovie) {
              if (tmdbId != null && radarrMovie.tmdbId == tmdbId) {
                return true;
              }
              return radarrMovie.title?.toLowerCase() == title.toLowerCase();
            });
            movie['inLibrary'] = inLibrary;

            if (inLibrary) {
              final radarrMovie = radarrMovies.firstWhere(
                (m) =>
                    (tmdbId != null && m.tmdbId == tmdbId) ||
                    m.title?.toLowerCase() == title.toLowerCase(),
              );
              movie['serviceItemId'] = radarrMovie.id;
            }
          }
        } catch (e) {
          // Silent fail - library check is optional
        }
      }

      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
        _currentPage = 1;
        _hasMorePages = movies.isNotEmpty;
        _error = null;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load movies for studio', error, stack);
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
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final nextPage = _currentPage + 1;
      final movies = await TMDBApi.getMoviesByStudio(
        widget.studioId,
        page: nextPage,
        region: region,
      );

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        try {
          final radarrMovies = await radarrState.movies!;

          for (final movie in movies) {
            final tmdbId = movie['tmdbId'] as int?;
            final title = movie['title'] as String;

            final inLibrary = radarrMovies.any((radarrMovie) {
              if (tmdbId != null && radarrMovie.tmdbId == tmdbId) {
                return true;
              }
              return radarrMovie.title?.toLowerCase() == title.toLowerCase();
            });
            movie['inLibrary'] = inLibrary;

            if (inLibrary) {
              final radarrMovie = radarrMovies.firstWhere(
                (m) =>
                    (tmdbId != null && m.tmdbId == tmdbId) ||
                    m.title?.toLowerCase() == title.toLowerCase(),
              );
              movie['serviceItemId'] = radarrMovie.id;
            }
          }
        } catch (e) {
          // Silent fail
        }
      }

      setState(() {
        _movies.addAll(movies);
        _currentPage = nextPage;
        _hasMorePages = movies.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
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
      title: widget.studioName,
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: ZagLoader(),
      );
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
            Text(
              'Error Loading ${widget.studioName} Movies',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMovies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Movies Found for ${widget.studioName}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final savedColumns = _getColumnsForDevice(context);
    final usesThreeColumns = savedColumns == 3;
    final horizontalPadding = usesThreeColumns ? 20.0 : 16.0;

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

    // Adjust aspect ratio when titles are beneath (need more vertical space for title)
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;

    return RefreshIndicator(
      onRefresh: _loadMovies,
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
          if (index == _movies.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
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
    final showOverlayTitle = _showTitles && 
        false;
    final showTitleBeneath = (_showTitles) &&
        true;

    return GestureDetector(
      onTap: () => _handleMovieTap(movie),
      child: showTitleBeneath
          ? _buildTileWithTitleBeneath(movie, inLibrary)
          : _buildTileWithOverlayTitle(movie, inLibrary),
    );
  }

  Widget _buildTileWithTitleBeneath(
    Map<String, dynamic> movie,
    bool inLibrary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade800,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPosterImage(movie),
                  if (inLibrary)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEC333),
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
                  if (movie['rating'] != null && movie['rating'] > 0)
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
                          (movie['rating'] ?? 0.0).toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor((movie['rating'] ?? 0.0).toDouble()),
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
          movie['title'] ?? 'Unknown',
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
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade800,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPosterImage(movie),
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
            if (inLibrary)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEC333),
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
            if (movie['rating'] != null && movie['rating'] > 0)
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
                    (movie['rating'] ?? 0.0).toStringAsFixed(1),
                    style: TextStyle(
                      color: _ratingColor((movie['rating'] ?? 0.0).toDouble()),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_showTitles)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: AutoSizeText(
                  movie['title'] ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: _titleMaxLines,
                  minFontSize: 11,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
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

    await _openMovieInRadarr(
      tmdbId: tmdbId,
      title: title,
    );
  }

  Future<void> _openMovieInRadarr({int? tmdbId, String? title}) async {
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

    try {
      RadarrMovie? match;
      if (radarrState.movies != null) {
        final movies = await radarrState.movies!;
        final lowerTitle = title?.toLowerCase();
        if (lowerTitle != null && lowerTitle.isNotEmpty) {
          for (final movie in movies) {
            final candidate = movie.title?.toLowerCase();
            if (candidate != null && candidate == lowerTitle) {
              match = movie;
              break;
            }
          }
        }
      }

      if (match != null && match.id != null) {
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': match.id!.toString(),
          },
        );
        return;
      }

      final query = tmdbId != null
          ? 'tmdb:$tmdbId'
          : (title != null && title.trim().isNotEmpty ? title.trim() : '');

      if (query.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Radarr',
          message: 'Unable to open this movie in Radarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: ZagLoader()),
      );
      loaderShown = true;

      final results = await radarrState.api!.movieLookup.get(term: query);

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Radarr',
          message: tmdbId != null
              ? 'Could not find TMDB ID $tmdbId in Radarr.'
              : 'Could not find this movie in Radarr.',
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
      );
    } catch (error) {
      dismissLoader();
      if (!mounted) return;
      showZagSnackBar(
        title: title ?? 'Radarr',
        message: 'Something went wrong talking to Radarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Widget _buildPosterImage(Map<String, dynamic> movie) {
    final posterUrl = movie['poster'] as String?;

    if (posterUrl == null || posterUrl.isEmpty) {
      return _posterPlaceholder(movie);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(movie);
      },
    );
  }

  Widget _posterPlaceholder(Map<String, dynamic> movie) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 40,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                movie['title'] ?? 'Unknown',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getColumnsForDevice(BuildContext context) {
    if (ZagPlatform.isTablet(context)) {
      return ZagreusDatabase.DISCOVER_IPAD_COLUMNS_PER_ROW.read() ?? 4;
    }
    return ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
  }
}
