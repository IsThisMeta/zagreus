import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/discover/core/session_cache.dart';
import 'package:zagreus/system/platform.dart';

class DiscoverRecommendedRoute extends StatefulWidget {
  final List<RadarrMovie>? initialData;

  const DiscoverRecommendedRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<DiscoverRecommendedRoute> createState() => _State();
}

class _State extends State<DiscoverRecommendedRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;

  // Radarr multi-add settings
  int? _radarrQualityProfileId;
  String? _radarrQualityProfileName;
  String? _radarrRootFolder;
  bool _radarrSearchForMissing = true;

  // Multi-select mode
  bool _isMultiSelectMode = false;
  Set<int> _selectedMovieIndices = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();

    final cached = DiscoverSessionCache().get('DiscoverRecommendedRoute');
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
      _loadRecommendedMovies();
    }
  }

  @override
  void dispose() {
    if (_movies.isNotEmpty) {
      DiscoverSessionCache().set(
        'DiscoverRecommendedRoute',
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

  void _loadSavedSettings() {
    _radarrQualityProfileId =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _radarrQualityProfileName =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _radarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing =
        ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read();
  }

  Future<void> _loadRecommendedMovies() async {
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

      // Fetch recommended movies from Radarr's import lists
      // First, get all import lists
      final importLists = await api.importList.getAll();

      // Find import lists that are recommendations (like TMDB Popular, IMDB Top, etc)
      final recommendationLists = importLists.where((list) {
        return list.enabled == true &&
            (list.name?.toLowerCase().contains('popular') == true ||
                list.name?.toLowerCase().contains('top') == true ||
                list.name?.toLowerCase().contains('trending') == true ||
                list.name?.toLowerCase().contains('recommend') == true);
      }).toList();

      // If no recommendation lists, try to get from all enabled lists
      if (recommendationLists.isEmpty) {
        recommendationLists
            .addAll(importLists.where((list) => list.enabled == true).take(3));
      }

      // Fetch movies from import lists (Radarr's recommendations)
      final Set<int> tmdbIds = {};
      List<RadarrMovie> recommendedMovies = [];

      try {
        // Get all movies from import lists with recommendations
        recommendedMovies = await api.importList.getMovies(
          includeRecommendations: true,
        );

        // Remove duplicates by TMDB ID
        final uniqueMovies = <RadarrMovie>[];
        for (final movie in recommendedMovies) {
          if (movie.tmdbId != null && !tmdbIds.contains(movie.tmdbId)) {
            tmdbIds.add(movie.tmdbId!);
            uniqueMovies.add(movie);
          }
        }
        recommendedMovies = uniqueMovies;
      } catch (e) {
        ZagLogger().warning('Failed to fetch recommendations: $e');
      }

      // Sort by popularity or rating if available
      recommendedMovies.sort((a, b) {
        // Sort by year (newer first), then by title
        if (a.year != null && b.year != null) {
          final yearCompare = b.year!.compareTo(a.year!);
          if (yearCompare != 0) return yearCompare;
        }
        final aTitle = a.title ?? '';
        final bTitle = b.title ?? '';
        return aTitle.compareTo(bTitle);
      });

      // Limit to reasonable number for display
      final displayMovies = recommendedMovies.take(50).toList();

      if (!mounted) return;
      setState(() {
        _movies = displayMovies;
        _isLoading = false;
        _error = _movies.isEmpty
            ? 'No recommendations found. Make sure you have import lists configured in Radarr.'
            : null;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load recommended movies', error, stack);
      if (!mounted) return;
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
      title: 'discover.section.recommended'.tr(),
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
              'Error Loading Recommendations',
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
              onPressed: _loadRecommendedMovies,
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
              'No Recommendations Available',
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
        !(ZagreusDatabase.DISCOVER_TITLES_ON_POSTER.read() ?? false);

    // Adjust aspect ratio when titles are beneath
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;



    return RefreshIndicator(
      onRefresh: _loadRecommendedMovies,
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
        itemBuilder: (context, index) => _movieTile(_movies[index], index),
      ),
    );
  }

  Widget _movieTile(RadarrMovie movie, int index) {
    final isSelected = _selectedMovieIndices.contains(index);
    final titleFontSize = _getTitleFontSize(context);
    final showTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;
    final titlesBeneath = showTitles &&
        !(ZagreusDatabase.DISCOVER_TITLES_ON_POSTER.read() ?? false);

    return GestureDetector(
      onTap: () =>
          _isMultiSelectMode ? _toggleSelection(index) : _handleMovieTap(movie),
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(movie, isSelected, titleFontSize)
          : _buildTileWithOverlayTitle(movie, isSelected, titleFontSize),
    );
  }

  Widget _buildTileWithTitleBeneath(
    RadarrMovie movie,
    bool isSelected,
    double titleFontSize,
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
                  _buildPosterImage(context, movie),
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

  Widget _buildTileWithOverlayTitle(
    RadarrMovie movie,
    bool isSelected,
    double titleFontSize,
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
            _buildPosterImage(context, movie),
            // Gradient for text readability
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

  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    // Try to get poster URL - either from movie ID (if in library) or from images array
    String? posterUrl;

    if (movie.id != null) {
      // Movie is in library, use standard poster URL
      posterUrl = context.read<RadarrState>().getPosterURL(movie.id);
    } else if (movie.images?.isNotEmpty == true) {
      // Movie not in library but has images, extract poster URL from images array
      final posterImage = movie.images!.firstWhere(
        (img) => img.coverType?.toLowerCase().contains('poster') == true,
        orElse: () => movie.images!.first,
      );

      // Use remoteUrl if available, otherwise use url
      posterUrl = posterImage.remoteUrl ?? posterImage.url;
    }

    if (posterUrl == null) {
      return _posterPlaceholder(movie);
    }

    final headers = context.read<RadarrState>().headers;

    // Convert headers to Map<String, String>
    final stringHeaders = <String, String>{};
    headers.forEach((key, value) {
      stringHeaders[key.toString()] = value.toString();
    });

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      headers: stringHeaders.isNotEmpty ? stringHeaders : null,
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

  Future<void> _handleMovieTap(RadarrMovie movie) async {
    if (movie.id != null) {
      RadarrRoutes.MOVIE.go(
        params: {
          'movie': movie.id.toString(),
        },
      );
      return;
    }

    if (movie.tmdbId == null) {
      showZagSnackBar(
        title: movie.title ?? 'Movie',
        message: 'Missing TMDB identifier for this recommendation.',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    RadarrRoutes.ADD_MOVIE_DETAILS.go(
      extra: movie,
      queryParams: {'isDiscovery': 'true'},
    );
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
        if (movie.tmdbId == null) {
          failCount++;
          continue;
        }

        // Lookup movie on TMDB
        final lookupResults = await radarrState.api!.movieLookup.get(
          term: "tmdb:${movie.tmdbId}",
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
        ZagLogger().warning('Failed to add movie ${movie.title}: $e');
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
    _loadRecommendedMovies();
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
