import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/modules/radarr/core/dialogs.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/system/platform.dart';

class DiscoverRecentlyDownloadedRoute extends StatefulWidget {
  final List<RadarrMovie>? initialData;

  const DiscoverRecentlyDownloadedRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<DiscoverRecentlyDownloadedRoute> createState() => _State();
}

class _State extends State<DiscoverRecentlyDownloadedRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    final cached = DiscoverSessionCache().get('DiscoverRecentlyDownloadedRoute');
    if (cached != null) {
      _movies = List<RadarrMovie>.from(cached.items);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
    } else if (widget.initialData?.isNotEmpty == true) {
      _movies = List<RadarrMovie>.from(widget.initialData!);
      _isLoading = false;
    } else {
      _loadRecentlyDownloaded();
    }
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'DiscoverRecentlyDownloadedRoute',
        DiscoverRouteState(
          items: _movies,
          currentPage: 1,
          scrollOffset:
              scrollController.hasClients ? scrollController.offset : 0.0,
          hasMorePages: false,
        ),
      );
    }
    super.dispose();
  }

  Future<void> _loadRecentlyDownloaded() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        setState(() {
          _error = 'Radarr is not enabled';
          _isLoading = false;
        });
        return;
      }

      final api = radarrState.api;
      if (api == null) {
        setState(() {
          _error = 'Radarr API is not configured';
          _isLoading = false;
        });
        return;
      }

      // Fetch more history
      final history = await api.history.get(
        pageSize: 200, // Get more records
        sortDirection: RadarrSortDirection.DESCENDING,
        sortKey: RadarrHistorySortKey.DATE,
      );

      // Filter only downloaded items and get unique movie IDs
      final downloadedRecords = history.records?.where((record) {
            return record.eventType == RadarrEventType.DOWNLOAD_FOLDER_IMPORTED;
          }).toList() ??
          [];

      // Get unique movie IDs
      final movieIds = <int>{};
      for (final record in downloadedRecords) {
        if (record.movieId != null) {
          movieIds.add(record.movieId!);
        }
      }

      // Fetch all movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }

      // Wait for movies to load
      final allMovies = await radarrState.movies!;

      // Filter movies that are in the downloaded history
      final downloadedMovies = <RadarrMovie>[];
      for (final movieId in movieIds.take(40)) {
        // Show up to 40
        final movie = allMovies.firstWhere(
          (m) => m.id == movieId,
          orElse: () => RadarrMovie(),
        );
        if (movie.id != null) {
          downloadedMovies.add(movie);
        }
      }

      if (!mounted) return;
      setState(() {
        _movies = downloadedMovies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
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
      title: 'Recently Downloaded',
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: _loadRecentlyDownloaded,
        ),
      ],
    ) as PreferredSizeWidget;
  }

  Widget _body() {
    final screenWidth = MediaQuery.sizeOf(context).width;
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

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFEC333)),
        ),
      );
    }

    if (_error != null && _movies.isEmpty) {
      return ZagMessage.error(
        onTap: _loadRecentlyDownloaded,
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recently Downloaded',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No movies have been downloaded recently',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloaded,
      child: GridView.builder(
        cacheExtent: 2000.0,
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
          final movie = _movies[index];
          return _MovieGridItem(movie: movie, titleFontSize: _getTitleFontSize(context));
        },
      ),
    );
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
}

class _MovieGridItem extends StatelessWidget {
  final RadarrMovie movie;
  final double titleFontSize;

  const _MovieGridItem({
    Key? key,
    required this.movie,
    required this.titleFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': movie.id.toString(),
          },
        );
      },
      onLongPress:
          movie.id != null ? () => _showMovieActions(context, movie) : null,
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
              // Poster
              _buildPosterImage(context, movie),
              // Gradient for text readability
              if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              // Title
              if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: AutoSizeText(
                    movie.title ?? 'Unknown',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    minFontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    final posterUrl = context.read<RadarrState>().getPosterURL(movie.id);
    final headers = context.read<RadarrState>().headers;

    if (posterUrl == null) {
      return _posterPlaceholder(movie);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      headers: headers.isNotEmpty ? headers : null,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(movie);
      },
    );
  }

  Widget _posterPlaceholder(RadarrMovie movie) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_rounded,
              size: 40,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMovieActions(
      BuildContext context, RadarrMovie movie) async {
    HapticFeedback.lightImpact();
    final result = await RadarrDialogs().movieSettings(context, movie);
    if (result.item1 && result.item2 != null) {
      result.item2!.execute(context, movie);
    }
  }
}
