import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/system/platform.dart';

class DiscoverDownloadingSoonRoute extends StatefulWidget {
  final List<RadarrMovie>? initialData;

  const DiscoverDownloadingSoonRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<DiscoverDownloadingSoonRoute> createState() => _State();
}

class _State extends State<DiscoverDownloadingSoonRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _lookAheadDays = 28; // Default look-ahead period

  @override
  void initState() {
    super.initState();

    final cached = DiscoverSessionCache().get('DiscoverDownloadingSoonRoute');
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
      _loadDownloadingSoon();
    }
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'DiscoverDownloadingSoonRoute',
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

  Future<void> _loadDownloadingSoon() async {
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

      // Fetch all movies
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }

      final allMovies = await radarrState.movies!;

      // Filter movies that are:
      // 1. Monitored
      // 2. Not downloaded (no file)
      // 3. Available soon (within lookAheadDays window)
      final comingSoonMovies = <RadarrMovie>[];
      final now = DateTime.now();

      for (final movie in allMovies) {
        // Skip if not monitored or already downloaded
        if (movie.monitored != true || movie.hasFile == true) {
          continue;
        }

        // Try digital release first, then physical release (matching Zebrra logic)
        final releaseDate = movie.digitalRelease ?? movie.physicalRelease;

        if (releaseDate != null) {
          // Calculate days using UTC dates (matching Zebrra)
          final nowUtc = now.toUtc();
          final releaseDateUtc = releaseDate.toUtc();

          // Compare start of days in UTC
          final startOfTodayUtc =
              DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
          final startOfReleaseUtc = DateTime.utc(
              releaseDateUtc.year, releaseDateUtc.month, releaseDateUtc.day);

          final daysUntil =
              startOfReleaseUtc.difference(startOfTodayUtc).inDays;

          // Check if within look-ahead window
          if (daysUntil >= 0 && daysUntil <= _lookAheadDays) {
            comingSoonMovies.add(movie);
          }
        }
      }

      // Sort by release date (closest first)
      comingSoonMovies.sort((a, b) {
        final aDate = a.digitalRelease ?? a.physicalRelease;
        final bDate = b.digitalRelease ?? b.physicalRelease;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      if (!mounted) return;
      setState(() {
        _movies = comingSoonMovies;
        _isLoading = false;
        _error = _movies.isEmpty ? 'No movies downloading soon' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDaysUntil(RadarrMovie movie) {
    DateTime? releaseDate = movie.digitalRelease ?? movie.physicalRelease;

    // If no digital/physical release, try to estimate from cinema date
    if (releaseDate == null && movie.inCinemas != null) {
      releaseDate = movie.inCinemas!.add(const Duration(days: 90));
    }

    if (releaseDate == null) {
      if (movie.status == 'announced') {
        return 'Announced';
      } else if (movie.status == 'inCinemas') {
        return 'In Cinemas';
      } else {
        return 'TBA';
      }
    }

    // Use UTC date calculation to match filtering logic
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final releaseDateUtc = releaseDate.toUtc();

    // Compare start of days in UTC
    final startOfTodayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final startOfReleaseUtc = DateTime.utc(
        releaseDateUtc.year, releaseDateUtc.month, releaseDateUtc.day);

    final daysUntil = startOfReleaseUtc.difference(startOfTodayUtc).inDays;

    if (daysUntil < 0) {
      return 'TBA';
    } else if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else if (daysUntil < 7) {
      return 'In $daysUntil days';
    } else if (daysUntil < 14) {
      return 'Next week';
    } else if (daysUntil < 21) {
      return 'In 2 weeks';
    } else if (daysUntil < 28) {
      return 'In 3 weeks';
    } else {
      return 'In ${(daysUntil / 7).round()} weeks';
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
      title: 'discover.section.downloading_soon'.tr(),
      actions: [],
    ) as PreferredSizeWidget;
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
        ),
      );
    }

    if (_error != null && _movies.isEmpty) {
      return ZagMessage.error(
        onTap: _loadDownloadingSoon,
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Movies Downloading Soon',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All monitored movies are either\ndownloaded or not releasing soon',
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
    // Check if titles should be beneath posters
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        !(ZagreusDatabase.DISCOVER_TITLES_ON_POSTER.read() ?? false);

    // Adjust aspect ratio when titles are beneath (need more vertical space for title)
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;



    return RefreshIndicator(
      onRefresh: _loadDownloadingSoon,
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
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return _MovieGridItem(
            movie: movie,
            subtitle: _formatDaysUntil(movie),
            titleFontSize: _getTitleFontSize(context),
          );
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
  final String subtitle;
  final double titleFontSize;

  const _MovieGridItem({
    Key? key,
    required this.movie,
    required this.subtitle,
    required this.titleFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        !(ZagreusDatabase.DISCOVER_TITLES_ON_POSTER.read() ?? false);

    return GestureDetector(
      onTap: () {
        RadarrRoutes.MOVIE.go(
          params: {
            'movie': movie.id.toString(),
          },
        );
      },
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(context)
          : _buildTileWithOverlayTitle(context),
    );
  }

  Widget _buildTileWithTitleBeneath(BuildContext context) {
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
                  _buildPosterImage(context, movie),
                  // Orange gradient overlay for upcoming status
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5],
                      ),
                    ),
                  ),
                  // Release date badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtitle.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
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
          movie.title ?? 'Unknown',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTileWithOverlayTitle(BuildContext context) {
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
            // Poster
            _buildPosterImage(context, movie),
            // Orange gradient overlay for upcoming status
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Release date badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
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
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    String? imageUrl;
    final images = movie.images ?? [];
    for (var image in images) {
      if (image.coverType == 'poster') {
        imageUrl = image.remoteUrl ?? image.url;
        break;
      }
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _posterPlaceholder();
        },
      );
    }

    return _posterPlaceholder();
  }

  Widget _posterPlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 40,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
