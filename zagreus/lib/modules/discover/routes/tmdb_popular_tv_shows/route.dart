import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class TMDBPopularTVShowsRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBPopularTVShowsRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBPopularTVShowsRoute> createState() => _State();
}

class _State extends State<TMDBPopularTVShowsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _shows = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

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

  int get _titleMaxLines {
    return 3;
  }

  double get _titleFontSize {
    final savedColumns = ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
    return savedColumns == 2 ? 12.0 : (savedColumns == 4 ? 16.0 : 14.0);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    if (widget.initialData?.isNotEmpty == true) {
      _shows = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadPopularTVShows(silent: true);
        }
      });
    } else {
      _loadPopularTVShows();
    }

    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
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

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
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


  Future<void> _loadPopularTVShows({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final shows = await TMDBApi.getPopularTVShows(page: 1, region: region);

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

            // Check if this show is in Sonarr library
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
      ZagLogger().error('Failed to load popular TV shows', error, stack);
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
      final shows =
          await TMDBApi.getPopularTVShows(page: nextPage, region: region);

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
          // Silent fail - library check is optional
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
      title: 'Popular TV Shows',
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _showSonarrConfig,
          tooltip: 'Batch Add Settings',
        ),
        IconButton(
          icon: const Icon(Icons.checklist),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = true;
            });
          },
          tooltip: 'Multi-Select',
        ),
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadPopularTVShows,
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
            const Text(
              'Error Loading Popular TV Shows',
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
              onPressed: _loadPopularTVShows,
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
              'No Popular TV Shows Found',
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
    final savedColumns = ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
    final usesThreeColumns = savedColumns == 3;
    final horizontalPadding = usesThreeColumns ? 20.0 : 16.0;
    final gridSpacing = usesThreeColumns ? 16.0 : 12.0;

    return RefreshIndicator(
      onRefresh: _loadPopularTVShows,
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
    final int index = _shows.indexOf(show);
    final bool isSelected = _selectedShowIndices.contains(index);

    return GestureDetector(
      onTap: () => _isMultiSelectMode ? _toggleSelection(index) : _handleShowTap(show),
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
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              // Library indicator dot - top right
              if (inLibrary && !_isMultiSelectMode)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 12,
                    height: 12,
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
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
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
                      fontSize: _titleFontSize,
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
      ),
    );
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
        message: 'Connect Sonarr to manage shows from Discover.',
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

  void _showSonarrConfig() {
    // Helper to get monitor type enum from string
    final currentMonitorType = _sonarrMonitorType != null && _sonarrMonitorType!.isNotEmpty
        ? SonarrSeriesMonitorType.values.firstWhere(
            (type) => type.value == _sonarrMonitorType,
            orElse: () => SonarrSeriesMonitorType.ALL,
          )
        : SonarrSeriesMonitorType.ALL;

    // Helper to get series type enum from string
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
                        final profiles = await sonarrState.api!.profile.getQualityProfiles();

                        if (!mounted) return;

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
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: SonarrSeriesMonitorType.values.length,
                            itemBuilder: (context, index) {
                              final monitorType = SonarrSeriesMonitorType.values[index];
                              return ListTile(
                                title: Text(monitorType.zagName),
                                onTap: () {
                                  setState(() {
                                    _sonarrMonitorType = monitorType.value;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.update(monitorType.value);
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
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ListView.builder(
                            itemCount: SonarrSeriesType.values.length,
                            itemBuilder: (context, index) {
                              final seriesType = SonarrSeriesType.values[index];
                              return ListTile(
                                title: Text(seriesType.value?.toUpperCase() ?? 'Unknown'),
                                onTap: () {
                                  setState(() {
                                    _sonarrSeriesType = seriesType.value;
                                  });
                                  setModalState(() {});
                                  ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.update(seriesType.value);
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

    _loadPopularTVShows();
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
}
