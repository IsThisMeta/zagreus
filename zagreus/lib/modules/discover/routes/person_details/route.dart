import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPersonData();
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
      appBar: ZagAppBar(
        title: widget.personName,
      ) as PreferredSizeWidget,
      body: _isLoading ? _loadingBody() : _body(),
    );
  }

  Widget _loadingBody() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ZagColours.accent),
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
                      color: ZagColours.accent,
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
                          color: ZagColours.accent,
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
            color: ZagColours.accent,
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
          color: selected ? ZagColours.accent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ZagColours.accent : Colors.grey.shade700,
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

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final credit = _filteredCredits[index];
            return _creditCard(credit);
          },
          childCount: _filteredCredits.length,
        ),
      ),
    );
  }

  Widget _creditCard(Map<String, dynamic> credit) {
    return GestureDetector(
      onTap: () => _handleCreditTap(credit),
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
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                    // Year badge
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
                              color: ZagColours.accentLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Rating badge
                    if (credit['rating'] != null && credit['rating'] > 0)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 11,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                credit['rating'].toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              credit['title'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Role
            if (credit['role'] != null)
              Text(
                credit['role'],
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
