import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class PersonDetailsRoute extends StatefulWidget {
  final int personId;
  final String personName;

  const PersonDetailsRoute({
    Key? key,
    required this.personId,
    required this.personName,
  }) : super(key: key);

  @override
  State<PersonDetailsRoute> createState() => _State();
}

class _State extends State<PersonDetailsRoute>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? _personDetails;
  List<Map<String, dynamic>> _credits = [];
  List<Map<String, dynamic>> _filteredCredits = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // ALL, MOVIES, TV SHOWS
  String _selectedRole = 'ALL'; // ALL, CAST, CREW
  bool _expandedBio = false;

  // Radarr multi-add settings
  int? _radarrQualityProfileId;
  String? _radarrQualityProfileName;
  String? _radarrRootFolder;
  bool _radarrSearchForMissing = true;

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
  Set<int> _selectedCreditIndices = {};

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadPersonData();
  }

  void _loadSavedSettings() {
    _radarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _radarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _radarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read();

    _sonarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
    _sonarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.read();
    _sonarrRootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
    _sonarrMonitorType = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
    _sonarrSeriesType = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();
    _sonarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read();
    _sonarrSearchForCutoffUnmet = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read();
  }

  Future<void> _loadPersonData() async {
    try {
      // Load person details
      final details = await TMDBApi.getPersonDetails(widget.personId);

      // Load person credits
      final credits = await TMDBApi.getPersonCombinedCredits(widget.personId);

      setState(() {
        _personDetails = details;
        _credits = credits;
        _filteredCredits = credits;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      print('Error loading person data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCredits = _credits.where((credit) {
        // Filter by media type
        if (_selectedFilter == 'MOVIES' && credit['mediaType'] != 'movie')
          return false;
        if (_selectedFilter == 'TV SHOWS' && credit['mediaType'] != 'tv')
          return false;

        // Filter by role
        if (_selectedRole == 'CAST' && credit['creditType'] != 'cast')
          return false;
        if (_selectedRole == 'CREW' && credit['creditType'] != 'crew')
          return false;

        return true;
      }).toList();

      // Sort by release date (newest first)
      _filteredCredits.sort((a, b) {
        final aDate = a['releaseDate'] ?? '0000';
        final bDate = b['releaseDate'] ?? '0000';
        return bDate.compareTo(aDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _isLoading ? _loadingBody() : _body(),
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
              _selectedCreditIndices.clear();
            });
          },
        ),
        title: Text('${_selectedCreditIndices.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: _toggleSelectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedCreditIndices.isEmpty ? null : _addSelectedCredits,
            tooltip: 'Add Selected',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: widget.personName,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _showUnifiedConfig,
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
      ],
    ) as PreferredSizeWidget;
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedCreditIndices.length == _filteredCredits.length) {
        _selectedCreditIndices.clear();
      } else {
        _selectedCreditIndices = Set.from(List.generate(_filteredCredits.length, (i) => i));
      }
    });
  }

  Widget _loadingBody() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
      ),
    );
  }

  Widget _body() {
    if (_personDetails == null) {
      return ZagMessage.error(
        onTap: _loadPersonData,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _personInfoSection(),
        ),
        SliverToBoxAdapter(
          child: _filterSection(),
        ),
        _creditsSliverGrid(),
      ],
    );
  }

  Widget _personInfoSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile photo with shadow
              Hero(
                tag: 'person_${widget.personId}',
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _personDetails!['profilePath'] != null
                        ? Image.network(
                            _personDetails!['profilePath'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _profilePlaceholder();
                            },
                          )
                        : _profilePlaceholder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Person info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personDetails!['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_personDetails!['age'] != null)
                      _infoRow(
                        Icons.cake_rounded,
                        '${_personDetails!['age']} years old',
                      ),
                    if (_personDetails!['birthday'] != null)
                      _infoRow(
                        Icons.calendar_today_rounded,
                        _formatDate(_personDetails!['birthday']),
                      ),
                    if (_personDetails!['placeOfBirth'] != null)
                      _infoRow(
                        Icons.location_on_rounded,
                        _personDetails!['placeOfBirth'],
                      ),
                    if (_personDetails!['knownForDepartment'] != null)
                      _infoRow(
                        Icons.work_rounded,
                        _personDetails!['knownForDepartment'],
                      ),
                    if (_personDetails!['deathday'] != null)
                      _infoRow(
                        Icons.sentiment_very_dissatisfied_rounded,
                        _formatDate(_personDetails!['deathday']),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_personDetails!['biography'] != null &&
              _personDetails!['biography'].isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biography',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ZagColours.currentAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _personDetails!['biography'],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.grey[300],
                    ),
                    maxLines: _expandedBio ? null : 4,
                    overflow: _expandedBio
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if ((_personDetails!['biography'] as String).length > 200)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandedBio = !_expandedBio;
                        });
                      },
                      child: Text(
                        _expandedBio ? 'Show Less' : 'Read More',
                        style: TextStyle(
                          color: ZagColours.currentAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: ZagColours.currentAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[300],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _filterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filmography (${_filteredCredits.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  'All',
                  Icons.all_inclusive_rounded,
                  _selectedFilter == 'ALL',
                  () {
                    setState(() => _selectedFilter = 'ALL');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Movies',
                  Icons.movie_rounded,
                  _selectedFilter == 'MOVIES',
                  () {
                    setState(() => _selectedFilter = 'MOVIES');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'TV Shows',
                  Icons.tv_rounded,
                  _selectedFilter == 'TV SHOWS',
                  () {
                    setState(() => _selectedFilter = 'TV SHOWS');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 16),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 16),
                _filterChip(
                  'Acting',
                  Icons.theater_comedy_rounded,
                  _selectedRole == 'CAST',
                  () {
                    setState(() => _selectedRole = 'CAST');
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                _filterChip(
                  'Crew',
                  Icons.engineering_rounded,
                  _selectedRole == 'CREW',
                  () {
                    setState(() => _selectedRole = 'CREW');
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ZagColours.currentAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ZagColours.currentAccent : Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.black : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.black : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditsSliverGrid() {
    if (_filteredCredits.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter_rounded,
                  size: 48,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 8),
                Text(
                  'No credits found',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final usesThreeColumns = screenWidth >= 360;
    final horizontalPadding = usesThreeColumns ? 16.0 : 12.0;
    final gridSpacing = usesThreeColumns ? 12.0 : 10.0;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        16,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: usesThreeColumns ? 3 : 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final credit = _filteredCredits[index];
            return _creditCard(credit, index);
          },
          childCount: _filteredCredits.length,
        ),
      ),
    );
  }

  Widget _creditCard(Map<String, dynamic> credit, int index) {
    final isSelected = _selectedCreditIndices.contains(index);

    return GestureDetector(
      onTap: () => _isMultiSelectMode ? _toggleSelection(index) : _handleCreditTap(credit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with shadow
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: credit['posterPath'] != null
                          ? Image.network(
                              credit['posterPath'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return _posterPlaceholder();
                              },
                            )
                          : _posterPlaceholder(),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Title at bottom
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        credit['title'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Year badge - top-left
                    if (credit['year'] != null)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            credit['year'],
                            style: TextStyle(
                              color: ZagColours.currentAccentLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Rating badge - top-left (below year if present)
                    if (credit['rating'] != null && credit['rating'] > 0)
                      Positioned(
                        top: credit['year'] != null ? 32 : 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            credit['rating'].toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Selection indicator
                    if (_isMultiSelectMode)
                      Positioned(
                        top: 6,
                        right: 6,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Icon(
        Icons.person_rounded,
        size: 60,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Icon(
        Icons.movie_rounded,
        size: 30,
        color: Colors.grey.shade500,
      ),
    );
  }

  Future<void> _openMovieInRadarr({required int tmdbId, String? title}) async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: title ?? 'Radarr',
        message: 'Connect Radarr to manage movies from filmography.',
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
    } catch (error) {
      dismissLoader();
      if (!mounted) return;
      showZagSnackBar(
        title: title ?? 'Movie',
        message: 'Something went wrong talking to Radarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _openSeriesInSonarr({int? tmdbId, String? title}) async {
    final sonarrState = context.read<SonarrState>();
    if (!sonarrState.enabled || sonarrState.api == null) {
      showZagSnackBar(
        title: title ?? 'Sonarr',
        message: 'Connect Sonarr to manage shows from filmography.',
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
          : (title != null && title.isNotEmpty ? title : '');

      if (query.isEmpty) {
        showZagSnackBar(
          title: title ?? 'Sonarr',
          message: 'Unable to open this show in Sonarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      if (tmdbId == null) {
        SonarrRoutes.ADD_SERIES.go(
          queryParams: {
            'query': query,
          },
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
          message: 'Could not find TMDB ID $tmdbId in Sonarr.',
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
      showZagSnackBar(
        title: title ?? 'Sonarr',
        message: 'Something went wrong talking to Sonarr.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedCreditIndices.contains(index)) {
        _selectedCreditIndices.remove(index);
      } else {
        _selectedCreditIndices.add(index);
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
                  final profiles = await radarrState.api!.qualityProfile.getAll();

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
                            ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(profile.id);
                            ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(profile.name);
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
                            ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(folder.path);
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
                  ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.update(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSonarrConfig() {
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
                'Sonarr Batch Add Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.hd),
                title: const Text('Quality Profile'),
                subtitle: Text(_sonarrQualityProfileName ?? 'Not selected'),
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
                            setModalState(() {
                              _sonarrQualityProfileId = profile.id;
                              _sonarrQualityProfileName = profile.name;
                            });
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
                            setModalState(() {
                              _sonarrRootFolder = folder.path;
                            });
                            ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.update(folder.path);
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
                value: _sonarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    _sonarrSearchForMissing = value;
                  });
                  ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.update(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnifiedConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
                child: TabBar(
                  labelColor: ZagColours.currentAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: ZagColours.currentAccent,
                  tabs: const [
                    Tab(text: 'Movies'),
                    Tab(text: 'TV Shows'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRadarrSettings(),
                    _buildSonarrSettings(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarrSettings() {
    return StatefulBuilder(
      builder: (context, setModalState) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Quality Profile'),
            subtitle: Text(_radarrQualityProfileName ?? 'Not selected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final radarrState = context.read<RadarrState>();
              final profiles = await radarrState.api!.qualityProfile.getAll();

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
                          _radarrQualityProfileId = profile.id;
                          _radarrQualityProfileName = profile.name;
                        });
                        setModalState(() {});
                        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(profile.id);
                        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(profile.name);
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
            trailing: const Icon(Icons.chevron_right),
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
                        setState(() {
                          _radarrRootFolder = folder.path;
                        });
                        setModalState(() {});
                        ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(folder.path);
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
            value: _radarrSearchForMissing,
            onChanged: (value) {
              setState(() {
                _radarrSearchForMissing = value;
              });
              setModalState(() {});
              ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.update(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSonarrSettings() {
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

    return StatefulBuilder(
      builder: (context, setModalState) => ListView(
        padding: const EdgeInsets.all(16),
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
    );
  }

  Future<void> _addSelectedCredits() async {
    final selectedCredits = _selectedCreditIndices.map((i) => _filteredCredits[i]).toList();

    final movies = selectedCredits.where((c) => c['mediaType'] == 'movie').toList();
    final shows = selectedCredits.where((c) => c['mediaType'] == 'tv').toList();

    int movieSuccess = 0;
    int movieFail = 0;
    int showSuccess = 0;
    int showFail = 0;

    // Add movies to Radarr
    if (movies.isNotEmpty) {
      if (_radarrQualityProfileId == null || _radarrRootFolder == null) {
        showZagSnackBar(
          title: 'Radarr Configuration Required',
          message: 'Please configure Radarr settings first',
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

      final profiles = await radarrState.qualityProfiles;
      final folders = await radarrState.rootFolders;

      if (profiles != null && folders != null) {
        final selectedProfile = profiles.firstWhere(
          (p) => p.id == _radarrQualityProfileId,
          orElse: () => profiles.first,
        );
        final selectedFolder = folders.firstWhere(
          (f) => f.path == _radarrRootFolder,
          orElse: () => folders.first,
        );

        for (final movie in movies) {
          try {
            final tmdbId = movie['id'] as int?;
            if (tmdbId == null) {
              movieFail++;
              continue;
            }

            final lookupResults = await radarrState.api!.movieLookup.get(
              term: "tmdb:$tmdbId",
            );

            if (lookupResults.isEmpty || (lookupResults.first.id != null && lookupResults.first.id! > 0)) {
              movieFail++;
              continue;
            }

            await radarrState.api!.movie.create(
              movie: lookupResults.first,
              rootFolder: selectedFolder,
              monitored: true,
              minimumAvailability: RadarrAvailability.ANNOUNCED,
              qualityProfile: selectedProfile,
              searchForMovie: _radarrSearchForMissing,
            );

            movieSuccess++;
          } catch (e) {
            movieFail++;
          }
        }
      }
    }

    // Add shows to Sonarr
    if (shows.isNotEmpty) {
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

      if (profiles != null && folders != null) {
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

        for (final show in shows) {
          try {
            final tmdbId = show['id'] as int?;
            if (tmdbId == null) {
              showFail++;
              continue;
            }

            final lookupResults = await sonarrState.api!.seriesLookup.get(
              term: "tmdb:$tmdbId",
            );

            if (lookupResults.isEmpty || (lookupResults.first.id != null && lookupResults.first.id! > 0)) {
              showFail++;
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

            showSuccess++;
          } catch (e) {
            showFail++;
          }
        }
      }
    }

    showZagSnackBar(
      title: 'Batch Add Complete',
      message: 'Movies: $movieSuccess added, $movieFail failed. Shows: $showSuccess added, $showFail failed.',
      type: (movieSuccess > 0 || showSuccess > 0) ? ZagSnackbarType.SUCCESS : ZagSnackbarType.ERROR,
    );

    setState(() {
      _isMultiSelectMode = false;
      _selectedCreditIndices.clear();
    });

    _loadPersonData();
  }

  Future<void> _handleCreditTap(Map<String, dynamic> credit) async {
    final mediaType = credit['mediaType'] as String?;
    final dynamic rawId = credit['id'];
    final int? tmdbId = rawId is int
        ? rawId
        : rawId is num
            ? rawId.toInt()
            : null;
    final title = credit['title'] as String?;

    if (mediaType == 'movie') {
      if (tmdbId == null) {
        showZagSnackBar(
          title: title ?? 'Movie',
          message: 'Missing TMDB identifier for this title.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      await _openMovieInRadarr(
        tmdbId: tmdbId,
        title: title,
      );
      return;
    }

    if (mediaType == 'tv') {
      await _openSeriesInSonarr(
        tmdbId: tmdbId,
        title: title,
      );
      return;
    }

    showZagSnackBar(
      title: title ?? 'Unavailable',
      message: 'Unable to open this credit yet.',
      type: ZagSnackbarType.INFO,
    );
  }
}
