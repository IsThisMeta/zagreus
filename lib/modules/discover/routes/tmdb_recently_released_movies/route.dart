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

class TMDBRecentlyReleasedMoviesRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBRecentlyReleasedMoviesRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBRecentlyReleasedMoviesRoute> createState() => _State();
}

class _State extends State<TMDBRecentlyReleasedMoviesRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  // Radarr multi-add settings
  int? _radarrQualityProfileId;
  String? _radarrQualityProfileName;
  String? _radarrRootFolder;
  bool _radarrSearchForMissing = true;

  // Multi-select mode
  bool _isMultiSelectMode = false;
  Set<int> _selectedMovieIndices = {};

  int get _titleMaxLines {
    return 3;
  }

  double _getTitleFontSize(BuildContext context) {
    final savedColumns = _getColumnsForDevice(context);
    if (savedColumns >= 6) return 12.0;
    if (savedColumns == 5) return 13.0;
    return savedColumns == 2 ? 16.0 : (savedColumns == 4 ? 16.0 : 14.0);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();

    final cached =
        DiscoverSessionCache().get('TMDBRecentlyReleasedMoviesRoute');
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
    } else if (widget.initialData?.isNotEmpty == true) {
      _movies = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadRecentlyReleasedMovies(silent: true);
        }
      });
    } else {
      _loadRecentlyReleasedMovies();
    }

    // Add scroll listener for pagination
    scrollController.addListener(_scrollListener);
  }

  void _loadSavedSettings() {
    _radarrQualityProfileId =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _radarrQualityProfileName =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _radarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing =
        ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read();
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'TMDBRecentlyReleasedMoviesRoute',
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

  Future<void> _loadRecentlyReleasedMovies({bool silent = false}) async {
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

      final movies =
          await TMDBApi.getRecentlyReleasedMovies(page: 1, region: region);

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.api != null) {
        try {
          radarrState.fetchMovies();
          final radarrMovies = await radarrState.movies!;

          for (final movie in movies) {
            final tmdbId = movie['tmdbId'] as int?;
            final title = movie['title'] as String;

            // Check if this movie is in Radarr library
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
          print('Failed to check Radarr library: $e');
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
      ZagLogger()
          .error('Failed to load recently released movies', error, stack);
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
      final movies = await TMDBApi.getRecentlyReleasedMovies(
          page: nextPage, region: region);

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.api != null) {
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
          print('Failed to check Radarr library: $e');
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
    if (_isMultiSelectMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = false;
              _selectedMovieIndices.clear();
            });
          },
        ),
        title: Text('${_selectedMovieIndices.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showRadarrConfig,
            tooltip: 'Radarr Settings',
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _toggleSelectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedMovieIndices.isEmpty
                ? null
                : _addSelectedMoviesToRadarr,
            tooltip: 'Add Selected',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: 'discover.section.recently_released_movies'.tr(),
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
      if (_selectedMovieIndices.length == _movies.length) {
        _selectedMovieIndices.clear();
      } else {
        _selectedMovieIndices =
            Set.from(List.generate(_movies.length, (i) => i));
      }
    });
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Recently Released Movies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentlyReleasedMovies,
              child: Text('Retry'),
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
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Recently Released Movies Found',
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
      onRefresh: _loadRecentlyReleasedMovies,
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _movieTile(_movies[index], index);
        },
      ),
    );
  }

  Widget _movieTile(Map<String, dynamic> movie, int index) {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final int? serviceItemId = movie['serviceItemId'] as int?;
    final int? tmdbId = movie['tmdbId'] as int?;
    final isSelected = _selectedMovieIndices.contains(index);
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        (ZagreusDatabase.DISCOVER_TITLES_BENEATH_POSTER.read() ?? false);

    return GestureDetector(
      onTap: () => _isMultiSelectMode
          ? _toggleSelection(index)
          : _handleMovieTap(
              inLibrary: inLibrary,
              serviceItemId: serviceItemId,
              tmdbId: tmdbId,
              title: movie['title'] as String?,
            ),
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(movie, inLibrary, isSelected)
          : _buildTileWithOverlayTitle(movie, inLibrary, isSelected),
    );
  }

  Widget _buildTileWithTitleBeneath(
    Map<String, dynamic> movie,
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
                  _buildPosterImage(movie),
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
                  // Selection indicator
                  if (_isMultiSelectMode)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.5),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
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
            // Poster
            _buildPosterImage(movie),
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
                    stops: [0.0, 0.5, 1.0],
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
            if (movie['rating'] != null && movie['rating'] > 0)
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
                    (movie['rating'] ?? 0.0).toStringAsFixed(1),
                    style: TextStyle(
                      color:
                          _ratingColor((movie['rating'] ?? 0.0).toDouble()),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Selection indicator
            if (_isMultiSelectMode)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.blue
                        : Colors.white.withOpacity(0.5),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
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

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedMovieIndices.contains(index)) {
        _selectedMovieIndices.remove(index);
      } else {
        _selectedMovieIndices.add(index);
      }
    });
  }

  void _showRadarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Radarr Batch Add Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.hd),
                title: const Text('Quality Profile'),
                subtitle: Text(_radarrQualityProfileName ?? 'Not selected'),
                onTap: () async {
                  final radarrState = context.read<RadarrState>();
                  final profiles =
                      await radarrState.api!.qualityProfile.getAll();

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
                            setModalState(() {
                              _radarrQualityProfileId = profile.id;
                              _radarrQualityProfileName = profile.name;
                            });
                            ZagreusDatabase
                                .Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID
                                .update(profile.id);
                            ZagreusDatabase
                                .Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME
                                .update(profile.name);
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
                subtitle: Text(_radarrRootFolder ?? 'Not selected'),
                onTap: () async {
                  final radarrState = context.read<RadarrState>();
                  final folders = await radarrState.rootFolders;

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
                            setModalState(() {
                              _radarrRootFolder = folder.path;
                            });
                            ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER
                                .update(folder.path);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Search for Missing'),
                value: _radarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    _radarrSearchForMissing = value;
                  });
                  ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING
                      .update(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addSelectedMoviesToRadarr() async {
    if (_radarrQualityProfileId == null || _radarrRootFolder == null) {
      showZagSnackBar(
        title: 'Configuration Required',
        message: 'Please select both Quality Profile and Root Folder',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: 'Radarr Not Available',
        message: 'Radarr is not enabled or configured',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    // Get profiles and folders
    final profiles = await radarrState.qualityProfiles;
    final folders = await radarrState.rootFolders;

    if (profiles == null || folders == null) {
      showZagSnackBar(
        title: 'Configuration Error',
        message: 'Could not fetch Radarr configuration',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final selectedProfile = profiles.firstWhere(
      (p) => p.id == _radarrQualityProfileId,
      orElse: () => profiles.first,
    );
    final selectedFolder = folders.firstWhere(
      (f) => f.path == _radarrRootFolder,
      orElse: () => folders.first,
    );

    // Get selected movies
    final selectedMovies =
        _selectedMovieIndices.map((i) => _movies[i]).toList();

    showZagSnackBar(
      title: 'Adding Movies',
      message: 'Adding ${selectedMovies.length} movies to Radarr...',
      type: ZagSnackbarType.INFO,
    );

    int successCount = 0;
    int failCount = 0;

    for (final movie in selectedMovies) {
      try {
        final tmdbId = movie['tmdbId'] as int?;
        if (tmdbId == null) {
          failCount++;
          continue;
        }

        // Lookup movie on TMDB
        final lookupResults = await radarrState.api!.movieLookup.get(
          term: "tmdb:$tmdbId",
        );

        if (lookupResults.isEmpty) {
          failCount++;
          continue;
        }

        final radarrMovie = lookupResults.first;

        // Check if already in library
        if (radarrMovie.id != null && radarrMovie.id! > 0) {
          failCount++;
          continue;
        }

        // Add to Radarr
        await radarrState.api!.movie.create(
          movie: radarrMovie,
          rootFolder: selectedFolder,
          monitored: true,
          minimumAvailability: RadarrAvailability.ANNOUNCED,
          qualityProfile: selectedProfile,
          searchForMovie: _radarrSearchForMissing,
        );

        successCount++;
      } catch (e) {
        failCount++;
        ZagLogger().warning('Failed to add movie ${movie['title']}: $e');
      }
    }

    showZagSnackBar(
      title: 'Batch Add Complete',
      message: 'Added $successCount movies. $failCount failed.',
      type: successCount > 0 ? ZagSnackbarType.SUCCESS : ZagSnackbarType.ERROR,
    );

    // Exit multi-select mode
    setState(() {
      _isMultiSelectMode = false;
      _selectedMovieIndices.clear();
    });

    // Refresh the list
    _loadRecentlyReleasedMovies();
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
              Icons.movie_rounded,
              size: 40,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
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

  Future<void> _handleMovieTap({
    required bool inLibrary,
    required int? serviceItemId,
    required int? tmdbId,
    required String? title,
  }) async {
    if (inLibrary && serviceItemId != null) {
      RadarrRoutes.MOVIE.go(
        params: {
          'movie': serviceItemId.toString(),
        },
      );
      return;
    }

    if (tmdbId == null) {
      showZagSnackBar(
        title: title ?? 'Movie',
        message: 'Missing TMDB identifier for this title.',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: 'Radarr Unavailable',
        message: 'Connect Radarr to add movies from Dashboard.',
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

  int _getColumnsForDevice(BuildContext context) {
    if (ZagPlatform.isTablet(context)) {
      return ZagreusDatabase.DISCOVER_IPAD_COLUMNS_PER_ROW.read() ?? 4;
    }
    return ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
  }
}
