import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/system/platform.dart';

class TvGenreDiscoverRoute extends StatefulWidget {
  final int genreId;
  final String genreName;
  final String? backdropUrl;

  const TvGenreDiscoverRoute({
    Key? key,
    required this.genreId,
    required this.genreName,
    this.backdropUrl,
  }) : super(key: key);

  @override
  State<TvGenreDiscoverRoute> createState() => _State();
}

class _State extends State<TvGenreDiscoverRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _shows = [];
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

    final cacheKey = 'TvGenreDiscoverRoute_${widget.genreId}';
    final cached = DiscoverSessionCache().get(cacheKey);
    if (cached != null) {
      _shows = List<Map<String, dynamic>>.from(cached.items);
      _currentPage = cached.currentPage;
      _hasMorePages = cached.hasMorePages;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
    } else {
      _loadShows();
    }

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (_shows.isNotEmpty) {
      DiscoverSessionCache().set(
        'TvGenreDiscoverRoute_${widget.genreId}',
        DiscoverRouteState(
          items: _shows,
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
        _loadMoreShows();
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

  Future<void> _loadShows({bool silent = false}) async {
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

      final shows = await TMDBApi.getTvByGenre(
        widget.genreId,
        page: 1,
        region: region,
      );

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          sonarrState.fetchAllSeries();
          final sonarrSeriesMap = await sonarrState.series!;
          final sonarrSeries = sonarrSeriesMap.values.toList();

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            final inLibrary = sonarrSeries.any((sonarrShow) {
              if (tvdbId != null && sonarrShow.tvdbId == tvdbId) {
                return true;
              }
              return sonarrShow.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final sonarrShow = sonarrSeries.firstWhere(
                (s) =>
                    (tvdbId != null && s.tvdbId == tvdbId) ||
                    s.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = sonarrShow.id;
            }
          }
        } catch (e) {
          // Silent fail - library check is optional
        }
      }

      if (!mounted) return;
      setState(() {
        _shows = shows;
        _isLoading = false;
        _currentPage = 1;
        _hasMorePages = shows.isNotEmpty;
        _error = null;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load shows for genre', error, stack);
      if (!mounted) return;
      if (silent && _shows.isNotEmpty) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreShows() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final nextPage = _currentPage + 1;
      final shows = await TMDBApi.getTvByGenre(
        widget.genreId,
        page: nextPage,
        region: region,
      );

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          final sonarrSeriesMap = await sonarrState.series!;
          final sonarrSeries = sonarrSeriesMap.values.toList();

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            final inLibrary = sonarrSeries.any((sonarrShow) {
              if (tvdbId != null && sonarrShow.tvdbId == tvdbId) {
                return true;
              }
              return sonarrShow.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final sonarrShow = sonarrSeries.firstWhere(
                (s) =>
                    (tvdbId != null && s.tvdbId == tvdbId) ||
                    s.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = sonarrShow.id;
            }
          }
        } catch (e) {
          // Silent fail
        }
      }

      setState(() {
        _shows.addAll(shows);
        _currentPage = nextPage;
        _hasMorePages = shows.isNotEmpty;
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
      title: widget.genreName,
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: ZagLoader(),
      );
    }

    if (_error != null && _shows.isEmpty) {
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
              'Error Loading ${widget.genreName} Shows',
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
              onPressed: _loadShows,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.tv_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Shows Found for ${widget.genreName}',
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
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        (ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);

    // Adjust aspect ratio when titles are beneath (need more vertical space for title)
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;

    return RefreshIndicator(
      onRefresh: _loadShows,
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
        itemCount: _shows.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _shows.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _showTile(_shows[index]);
        },
      ),
    );
  }

  Widget _showTile(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final showOverlayTitle = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() && 
        !(ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);
    final showTitleBeneath = (ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true) &&
        (ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);

    return GestureDetector(
      onTap: () => _handleShowTap(show),
      child: showTitleBeneath
          ? _buildTileWithTitleBeneath(show, inLibrary)
          : _buildTileWithOverlayTitle(show, inLibrary),
    );
  }

  Widget _buildTileWithTitleBeneath(
    Map<String, dynamic> show,
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
                  _buildPosterImage(show),
                  if (inLibrary)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3FB4E8),
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
                  if (show['rating'] != null && show['rating'] > 0)
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
                          (show['rating'] ?? 0.0).toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor((show['rating'] ?? 0.0).toDouble()),
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
          show['title'] ?? 'Unknown',
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTileWithOverlayTitle(
    Map<String, dynamic> show,
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
            _buildPosterImage(show),
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
                    color: const Color(0xFF3FB4E8),
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
            if (show['rating'] != null && show['rating'] > 0)
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
                    (show['rating'] ?? 0.0).toStringAsFixed(1),
                    style: TextStyle(
                      color: _ratingColor((show['rating'] ?? 0.0).toDouble()),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: AutoSizeText(
                  show['title'] ?? 'Unknown',
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

    Future<void> _handleShowTap(Map<String, dynamic> show) async {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;
    final String? title = show['title'] as String?;

    if (inLibrary && serviceItemId != null) {
      SonarrRoutes.SERIES.go(
        params: {
          'series': serviceItemId.toString(),
        },
      );
      return;
    }

    await _openSeriesInSonarr(
      tmdbId: tmdbId,
      title: title,
    );
  }

  Future<void> _openSeriesInSonarr({int? tmdbId, String? title}) async {
    final sonarrState = context.read<SonarrState>();
    if (!sonarrState.enabled || sonarrState.api == null) {
      showZagSnackBar(
        title: title ?? 'Sonarr',
        message: 'Connect Sonarr to manage shows from Dashboard.',
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
      SonarrSeries? match;
      if (sonarrState.series != null) {
        final seriesMap = await sonarrState.series!;
        final lowerTitle = title?.toLowerCase();
        if (lowerTitle != null && lowerTitle.isNotEmpty) {
          for (final series in seriesMap.values) {
            final candidate = series.title?.toLowerCase();
            if (candidate != null && candidate == lowerTitle) {
              match = series;
              break;
            }
          }
        }
      }

      if (match != null && match.id != null) {
        SonarrRoutes.SERIES.go(
          params: {
            'series': match.id!.toString(),
          },
        );
        return;
      }

      final query = tmdbId != null
          ? 'tmdb:$tmdbId'
          : (title != null && title.trim().isNotEmpty ? title.trim() : '');

      if (query.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Sonarr',
          message: 'Unable to open this show in Sonarr.',
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

      final results = await sonarrState.api!.seriesLookup.get(term: query);

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Sonarr',
          message: tmdbId != null
              ? 'Could not find TMDB ID $tmdbId in Sonarr.'
              : 'Could not find this show in Sonarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final sonarrSeries = results.first;

      if (sonarrSeries.id != null) {
        SonarrRoutes.SERIES.go(
          params: {
            'series': sonarrSeries.id!.toString(),
          },
        );
        return;
      }

      SonarrRoutes.ADD_SERIES_DETAILS.go(
        extra: sonarrSeries,
      );
    } catch (error) {
      dismissLoader();
      if (!mounted) return;
      showZagSnackBar(
        title: title ?? 'Sonarr',
        message: 'Something went wrong talking to Sonarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Widget _buildPosterImage(Map<String, dynamic> show) {
    final posterUrl = show['poster'] as String?;

    if (posterUrl == null || posterUrl.isEmpty) {
      return _posterPlaceholder(show);
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder(show);
      },
    );
  }

  Widget _posterPlaceholder(Map<String, dynamic> show) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv,
              size: 40,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                show['title'] ?? 'Unknown',
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
