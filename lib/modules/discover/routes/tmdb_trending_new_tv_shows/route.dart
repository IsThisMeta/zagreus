import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/system/platform.dart';

class TMDBTrendingNewTVShowsRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBTrendingNewTVShowsRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBTrendingNewTVShowsRoute> createState() => _State();
}

class _State extends State<TMDBTrendingNewTVShowsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _shows = [];
  bool _isLoading = true;
  String? _error;

  // Sonarr multi-add settings
  int? _sonarrQualityProfileId;
  String? _sonarrQualityProfileName;
  String? _sonarrRootFolder;
  String? _sonarrMonitorType;
  String? _sonarrSeriesType;
  bool _sonarrSearchForMissing = true;
  bool _sonarrSearchForCutoffUnmet = false;

  // Multi-select mode
  bool _isMultiSelectMode = false;
  Set<int> _selectedShowIndices = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();

    final cached = DiscoverSessionCache().get('TMDBTrendingNewTVShowsRoute');
    if (cached != null) {
      _shows = List<Map<String, dynamic>>.from(cached.items);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(cached.scrollOffset);
        }
      });
    } else if (widget.initialData?.isNotEmpty == true) {
      _shows = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadTrendingShows(silent: true);
        }
      });
    } else {
      _loadTrendingShows();
    }
  }

  @override
  void dispose() {
    if (_shows.isNotEmpty) {
      DiscoverSessionCache().set(
        'TMDBTrendingNewTVShowsRoute',
        DiscoverRouteState(
          items: _shows,
          currentPage: 1,
          scrollOffset:
              scrollController.hasClients ? scrollController.offset : 0.0,
          hasMorePages: false,
        ),
      );
    }
    super.dispose();
  }

  void _loadSavedSettings() {
    _sonarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
    _sonarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.read();
    _sonarrRootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
    _sonarrMonitorType = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
    _sonarrSeriesType = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();
    _sonarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read();
    _sonarrSearchForCutoffUnmet = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read();
  }

  Future<void> _loadTrendingShows({bool silent = false}) async {
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

      final shows = await TMDBApi.getTrendingNewTVShows(region: region);

      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          sonarrState.fetchAllSeries();
          final sonarrSeriesMap = await sonarrState.series!;
          final sonarrSeries = sonarrSeriesMap.values.toList();

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            final inLibrary = sonarrSeries.any((series) {
              if (tvdbId != null && series.tvdbId == tvdbId) {
                return true;
              }
              return series.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final sonarrShow = sonarrSeries.firstWhere(
                (series) =>
                    (tvdbId != null && series.tvdbId == tvdbId) ||
                    series.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = sonarrShow.id;
            }
          }
        } catch (_) {
          // Library lookup failures shouldn't block the page
        }
      }

      if (!mounted) return;
      setState(() {
        _shows = shows;
        _isLoading = false;
        _error = null;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load trending TV shows', error, stack);
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

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    if (_isMultiSelectMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = false;
              _selectedShowIndices.clear();
            });
          },
        ),
        title: Text('${_selectedShowIndices.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSonarrConfig,
            tooltip: 'Batch Add Settings',
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _toggleSelectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedShowIndices.isEmpty ? null : _addSelectedShows,
            tooltip: 'Add Selected',
          ),
        ],
      ) as PreferredSizeWidget;
    }

    return ZagAppBar(
      title: 'Trending',
      actions: [
        IconButton(
          icon: const Icon(Icons.checklist),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = true;
            });
          },
          tooltip: 'Multi-Select',
        ),
      ],
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedShowIndices.length == _shows.length) {
        _selectedShowIndices.clear();
      } else {
        _selectedShowIndices = Set.from(List.generate(_shows.length, (i) => i));
      }
    });
  }

  Widget _body() {
    if (_isLoading) {
      return Center(child: ZagLoader());
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
            const Text(
              'Error Loading Trending Shows',
              style: TextStyle(
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
              onPressed: _loadTrendingShows,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shows.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Trending Shows Found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
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
        (ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);

    // Adjust aspect ratio when titles are beneath
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;



    return RefreshIndicator(
      onRefresh: _loadTrendingShows,
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
        itemCount: _shows.length,
        itemBuilder: (context, index) {
          return _showTile(_shows[index]);
        },
      ),
    );
  }

  Widget _showTile(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;
    final bool isNew = show['isNew'] == true;
    final int index = _shows.indexOf(show);
    final bool isSelected = _selectedShowIndices.contains(index);
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        (ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);

    return GestureDetector(
      onTap: () => _isMultiSelectMode ? _toggleSelection(index) : _handleShowTap(show),
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(show, inLibrary, isSelected)
          : _buildTileWithOverlayTitle(show, inLibrary, isSelected),
    );
  }

  Widget _buildTileWithTitleBeneath(
    Map<String, dynamic> show,
    bool inLibrary,
    bool isSelected,
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
                  // Library indicator - top right
                  if (inLibrary && !_isMultiSelectMode)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: ZagColours.blue,
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
                  // Selection indicator
                  if (_isMultiSelectMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                  // Rating badge - top left
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
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTileWithOverlayTitle(
    Map<String, dynamic> show,
    bool inLibrary,
    bool isSelected,
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
            // Gradient overlay for title
            if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
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
                  show['title'] ?? 'Unknown',
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
            // Library indicator - top right
            if (inLibrary && !_isMultiSelectMode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: ZagColours.blue,
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
            // Selection indicator
            if (_isMultiSelectMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            // Rating badge - top left
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
    );
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedShowIndices.contains(index)) {
        _selectedShowIndices.remove(index);
      } else {
        _selectedShowIndices.add(index);
      }
    });
  }

  Color _ratingColor(double rating) {
    final monochrome = ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.read();
    if (monochrome) {
      return Colors.white;
    }
    
    if (rating >= 8.0) {
      return const Color(0xFF64B5F6); // Pastel blue
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

  void _showSonarrConfig() {
    final currentMonitorType = _sonarrMonitorType != null && _sonarrMonitorType!.isNotEmpty
        ? SonarrSeriesMonitorType.values.firstWhere(
            (type) => type.value == _sonarrMonitorType,
            orElse: () => SonarrSeriesMonitorType.ALL,
          )
        : SonarrSeriesMonitorType.ALL;

    final currentSeriesType = _sonarrSeriesType != null && _sonarrSeriesType!.isNotEmpty
        ? SonarrSeriesType.values.firstWhere(
            (type) => type.value == _sonarrSeriesType,
            orElse: () => SonarrSeriesType.STANDARD,
          )
        : SonarrSeriesType.STANDARD;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sonarr Batch Add Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.high_quality),
                      title: const Text('Quality Profile'),
                      subtitle: Text(_sonarrQualityProfileName ?? 'Not selected'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final sonarrState = context.read<SonarrState>();
                        final profiles = await sonarrState.qualityProfiles;
                        if (!mounted || profiles == null) return;

                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: profiles.length,
                            itemBuilder: (context, index) {
                              final profile = profiles[index];
                              return ListTile(
                                title: Text(profile.name ?? 'Unknown'),
                                onTap: () {
                                  setState(() {
                                    _sonarrQualityProfileId = profile.id;
                                    _sonarrQualityProfileName = profile.name;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.update(profile.id);
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.update(profile.name);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder),
                      title: const Text('Root Folder'),
                      subtitle: Text(_sonarrRootFolder ?? 'Not selected'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final sonarrState = context.read<SonarrState>();
                        final folders = await sonarrState.rootFolders;
                        if (!mounted || folders == null) return;

                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: folders.length,
                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              return ListTile(
                                title: Text(folder.path ?? 'Unknown'),
                                onTap: () {
                                  setState(() {
                                    _sonarrRootFolder = folder.path;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.update(folder.path);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.view_list_rounded),
                      title: const Text('Monitoring Options'),
                      subtitle: Text(currentMonitorType.zagName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: SonarrSeriesMonitorType.values.length,
                            itemBuilder: (context, index) {
                              final type = SonarrSeriesMonitorType.values[index];
                              return ListTile(
                                title: Text(type.zagName),
                                onTap: () {
                                  setState(() {
                                    _sonarrMonitorType = type.value;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.update(type.value);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder_open_rounded),
                      title: const Text('Series Type'),
                      subtitle: Text(currentSeriesType.value?.toUpperCase() ?? 'STANDARD'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: SonarrSeriesType.values.length,
                            itemBuilder: (context, index) {
                              final type = SonarrSeriesType.values[index];
                              return ListTile(
                                title: Text(type.value?.toUpperCase() ?? 'Unknown'),
                                onTap: () {
                                  setState(() {
                                    _sonarrSeriesType = type.value;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.update(type.value);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.search),
                      title: const Text('Start search for missing'),
                      value: _sonarrSearchForMissing,
                      onChanged: (value) {
                        setState(() {
                          _sonarrSearchForMissing = value;
                        });
                        setModalState(() {});
                        ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.update(value);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.cut),
                      title: const Text('Search for cutoff unmet'),
                      value: _sonarrSearchForCutoffUnmet,
                      onChanged: (value) {
                        setState(() {
                          _sonarrSearchForCutoffUnmet = value;
                        });
                        setModalState(() {});
                        ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.update(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addSelectedShows() async {
    final selectedShows = _selectedShowIndices.map((i) => _shows[i]).toList();

    if (_sonarrQualityProfileId == null || _sonarrRootFolder == null) {
      showZagSnackBar(
        title: 'Sonarr Configuration Required',
        message: 'Please configure Sonarr settings first',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final sonarrState = context.read<SonarrState>();
    if (!sonarrState.enabled || sonarrState.api == null) {
      showZagSnackBar(
        title: 'Sonarr Not Available',
        message: 'Sonarr is not enabled or configured',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final profiles = await sonarrState.qualityProfiles;
    final folders = await sonarrState.rootFolders;

    if (profiles == null || folders == null) {
      showZagSnackBar(
        title: 'Sonarr Configuration Error',
        message: 'Could not load Sonarr profiles or folders',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final selectedProfile = profiles.firstWhere(
      (p) => p.id == _sonarrQualityProfileId,
      orElse: () => profiles.first,
    );
    final selectedFolder = folders.firstWhere(
      (f) => f.path == _sonarrRootFolder,
      orElse: () => folders.first,
    );

    final monitorType = _sonarrMonitorType != null && _sonarrMonitorType!.isNotEmpty
        ? SonarrSeriesMonitorType.values.firstWhere(
            (type) => type.value == _sonarrMonitorType,
            orElse: () => SonarrSeriesMonitorType.ALL,
          )
        : SonarrSeriesMonitorType.ALL;
    final seriesType = _sonarrSeriesType != null && _sonarrSeriesType!.isNotEmpty
        ? SonarrSeriesType.values.firstWhere(
            (type) => type.value == _sonarrSeriesType,
            orElse: () => SonarrSeriesType.STANDARD,
          )
        : SonarrSeriesType.STANDARD;

    int successCount = 0;
    int failCount = 0;

    for (final show in selectedShows) {
      try {
        final tmdbId = show['tmdbId'] as int?;
        if (tmdbId == null) {
          failCount++;
          continue;
        }

        final lookupResults = await sonarrState.api!.seriesLookup.get(
          term: "tmdb:$tmdbId",
        );

        if (lookupResults.isEmpty || (lookupResults.first.id != null && lookupResults.first.id! > 0)) {
          failCount++;
          continue;
        }

        await sonarrState.api!.series.create(
          series: lookupResults.first,
          rootFolder: selectedFolder,
          qualityProfile: selectedProfile,
          seriesType: seriesType,
          seasonFolder: true,
          searchForMissingEpisodes: _sonarrSearchForMissing,
          searchForCutoffUnmetEpisodes: _sonarrSearchForCutoffUnmet,
          monitorType: monitorType,
        );

        successCount++;
      } catch (e) {
        failCount++;
      }
    }

    showZagSnackBar(
      title: 'Batch Add Complete',
      message: '$successCount added, $failCount failed.',
      type: successCount > 0 ? ZagSnackbarType.SUCCESS : ZagSnackbarType.ERROR,
    );

    setState(() {
      _isMultiSelectMode = false;
      _selectedShowIndices.clear();
    });

    _loadTrendingShows();
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
