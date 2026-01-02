import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/system/platform.dart';

class DiscoverMissingRoute extends StatefulWidget {
  final List<RadarrMovie>? initialData;
  
  const DiscoverMissingRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<DiscoverMissingRoute> createState() => _State();
}

class _State extends State<DiscoverMissingRoute> with ZagScrollControllerMixin {
  bool get _showTitles => ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<RadarrMovie> _movies = [];
  bool _isLoading = true;
  String? _error;

  // Multi-select mode
  bool _isMultiSelectMode = false;
  Set<int> _selectedMovieIndices = {};
  
  @override
  void initState() {
    super.initState();
    if (widget.initialData?.isNotEmpty == true) {
      _movies = List<RadarrMovie>.from(widget.initialData!);
      _isLoading = false;
    } else {
      _loadMissingMovies();
    }
  }
  
  Future<void> _loadMissingMovies() async {
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
      
      // Fetch movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }
      
      // Get missing movies from state
      if (radarrState.missing == null) {
        setState(() {
          _error = 'Unable to fetch missing movies';
          _isLoading = false;
        });
        return;
      }
      
      final missingMovies = await radarrState.missing!;
      
      if (!mounted) return;
      setState(() {
        _movies = missingMovies;
        _isLoading = false;
        _error = _movies.isEmpty ? 'All movies downloaded!' : null;
      });
      
    } catch (error, stack) {
      ZagLogger().error('Failed to load missing movies', error, stack);
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
            icon: const Icon(Icons.select_all),
            onPressed: _toggleSelectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _selectedMovieIndices.isEmpty ? null : _searchForSelectedMovies,
            tooltip: 'Search Selected',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: 'Missing Movies',
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
        _selectedMovieIndices = Set.from(List.generate(_movies.length, (i) => i));
      }
    });
  }
  
  Widget _body() {
    if (_isLoading) {
      return Center(
        child: ZagLoader(),
      );
    }
    
    if (_error != null && _movies.isEmpty && _error != 'All movies downloaded!') {
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
              'Error Loading Missing Movies',
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
              onPressed: _loadMissingMovies,
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
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'All Movies Downloaded!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No missing movies in your library',
              style: TextStyle(
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
    final showTitles = _showTitles;
    final titlesBeneath = showTitles;

    // Adjust aspect ratio when titles are beneath
    final aspectRatio = titlesBeneath ? 0.48 : 0.58;



    return RefreshIndicator(
      onRefresh: _loadMissingMovies,
      child: GridView.builder(
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
    final showTitles = _showTitles;
    final titlesBeneath = showTitles;

    return GestureDetector(
      onTap: () => _isMultiSelectMode ? _toggleSelection(index) : _navigateToMovie(movie),
      child: titlesBeneath
          ? _buildTileWithTitleBeneath(movie, isSelected)
          : _buildTileWithOverlayTitle(movie, isSelected),
    );
  }

  Widget _buildTileWithTitleBeneath(
    RadarrMovie movie,
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
                  _buildPosterImage(context, movie),
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
          movie.title ?? 'Unknown',
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
    RadarrMovie movie,
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
            _buildPosterImage(context, movie),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: AutoSizeText(
                movie.title ?? 'Unknown',
                style: TextStyle(
                  fontSize: _getTitleFontSize(context),
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

  void _navigateToMovie(RadarrMovie movie) {
    RadarrRoutes.MOVIE.go(
      params: {
        'movie': movie.id.toString(),
      },
    );
  }

  Future<void> _searchForSelectedMovies() async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: 'Radarr Not Available',
        message: 'Radarr is not enabled or configured',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    final selectedMovies = _selectedMovieIndices.map((i) => _movies[i]).toList();

    showZagSnackBar(
      title: 'Searching',
      message: 'Searching for ${selectedMovies.length} missing movies...',
      type: ZagSnackbarType.INFO,
    );

    try {
      // Trigger search for all selected movies
      await radarrState.api!.command.moviesSearch(
        movieIds: selectedMovies.map((m) => m.id!).toList(),
      );

      showZagSnackBar(
        title: 'Search Started',
        message: 'Search started for ${selectedMovies.length} movies',
        type: ZagSnackbarType.SUCCESS,
      );

      // Exit multi-select mode
      setState(() {
        _isMultiSelectMode = false;
        _selectedMovieIndices.clear();
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to search for movies', e, stack);
      showZagSnackBar(
        title: 'Search Failed',
        message: 'Failed to start search: $e',
        type: ZagSnackbarType.ERROR,
      );
    }
  }
  
  Widget _buildPosterImage(BuildContext context, RadarrMovie movie) {
    final posterUrl = context.read<RadarrState>().getPosterURL(movie.id);
    final headers = context.read<RadarrState>().headers;
    
    if (posterUrl == null) {
      return _posterPlaceholder(movie);
    }
    
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
