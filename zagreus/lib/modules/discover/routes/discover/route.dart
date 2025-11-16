import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/overseerr/models.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/router/routes/discover.dart';
import 'package:zagreus/router/routes/search.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/discover/core/trakt_api.dart';
import 'package:zagreus/modules/discover/routes/person_details/route.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/dialogs.dart';
import 'package:zagreus/modules/discover/routes/sonarr_recently_downloaded/route.dart';
import 'package:zagreus/modules/discover/routes/sonarr_airing_next/route.dart';
import 'package:zagreus/modules/discover/routes/recently_downloaded/route.dart';
import 'package:zagreus/modules/discover/routes/downloading_soon/route.dart';
import 'package:zagreus/modules/discover/routes/missing/route.dart';
import 'package:zagreus/modules/discover/routes/recommended/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_popular_movies/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_popular_tv_shows/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_trending_new_tv_shows/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_popular_people/route.dart';
import 'package:zagreus/modules/discover/routes/trakt_most_anticipated_shows/route.dart';
import 'package:zagreus/modules/discover/routes/trakt_most_anticipated_movies/route.dart';
import 'package:zagreus/modules/discover/routes/z_assistant_results/route.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';
import 'package:zagreus/modules/discover/widgets/discover_sections_editor.dart';
import 'package:zagreus/modules/radarr/core/dialogs.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:zagreus/services/library_sync_service.dart';
import 'package:zagreus/services/watch_history_sync_service.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/services/deep_cuts_service.dart';
import 'package:zagreus/modules/overseerr/core/extensions.dart';
import 'package:zagreus/modules/overseerr/core/state.dart';
import 'package:zagreus/modules/sabnzbd/core/api/api.dart';
import 'package:zagreus/modules/server/core/download_history_fetcher.dart';
import 'package:zagreus/modules/server/routes/server/widgets/download_history_card.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/widgets/ui/block/block.dart';
import 'package:zagreus/widgets/ui/switch.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/calendar.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/modules.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/switch_view_action.dart';
import 'package:zagreus/modules/overseerr/routes/requests/widgets/request_tile.dart';

class DiscoverHomeRoute extends StatefulWidget {
  const DiscoverHomeRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverHomeRoute> createState() => _State();
}

class _UserOption {
  final String alias;
  final String label;

  const _UserOption({required this.alias, required this.label});
}

const double _userListExtraPadding = 32.0;
const EdgeInsets _moduleSectionTitlePadding =
    EdgeInsets.symmetric(horizontal: 16, vertical: 12);
const double _heroTitleFontSize = 26;
const double _posterAspectRatio = 2 / 3;
const int _discoverPreviewLimit = 10;
const int _discoverFullPageLimit = 60;
const double _recentlyDownloadedEpisodeThumbWidth = 100;
const double _recentlyDownloadedEpisodeThumbHeight = 53;
const int _overseerrPreviewLimit = 4;

class _State extends State<DiscoverHomeRoute> with ZagScrollControllerMixin {
  // Page storage + controller keys for scroll preservation
  static const _scrollIdRecentlyDownloaded = 'recently_downloaded_section';
  static const _scrollIdRecommended = 'recommended_movies_section';
  static const _scrollIdMissing = 'missing_movies_section';
  static const _scrollIdDownloadingSoon = 'downloading_soon_section';
  static const _scrollIdPopularMovies = 'popular_movies_section';
  static const _scrollIdPopularTv = 'popular_tv_shows_section';
  static const _scrollIdTrendingTv = 'trending_tv_shows_section';
  static const _scrollIdMostAnticipatedShows =
      'most_anticipated_shows_section';
  static const _scrollIdMostAnticipatedMovies =
      'most_anticipated_movies_section';
  static const _scrollIdPopularPeople = 'popular_people_section';
  static const _scrollIdDeepCuts = 'deep_cuts_recommendations';

  static const _recentlyDownloadedListKey =
      PageStorageKey<String>('discover_recently_downloaded_movies');
  static const _recommendedMoviesListKey =
      PageStorageKey<String>('discover_recommended_movies');
  static const _missingMoviesListKey =
      PageStorageKey<String>('discover_missing_movies');
  static const _downloadingSoonListKey =
      PageStorageKey<String>('discover_downloading_soon');
  static const _popularMoviesListKey =
      PageStorageKey<String>('discover_popular_movies');
  static const _popularTvShowsListKey =
      PageStorageKey<String>('discover_popular_tv_shows');
  static const _trendingTvShowsListKey =
      PageStorageKey<String>('discover_trending_tv_shows');
  static const _mostAnticipatedShowsListKey =
      PageStorageKey<String>('discover_most_anticipated_shows');
  static const _mostAnticipatedMoviesListKey =
      PageStorageKey<String>('discover_most_anticipated_movies');
  static const _popularPeopleListKey =
      PageStorageKey<String>('discover_popular_people');
  static const _deepCutsListKey =
      PageStorageKey<String>('discover_deep_cuts');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ZagPageController _pageController;
  int _currentPageIndex = 0;
  bool _isSearchActive = false;
  bool _isAgentActive = false;
  int _lastNonSearchPageIndex = 0;

  // Adjustable poster height
  double _posterHeight = 200.0;
  double get _posterWidth => _posterHeight * _posterAspectRatio;
  double get _posterListHeight => _posterHeight + 8.0;
  double get _moduleSectionTitleFontSize {
    if (_posterHeight >= 225) {
      return 20;
    }
    if (_posterHeight <= 175) {
      return 16;
    }
    return 18;
  }
  double _heroHeight = 370.0;

  List<RadarrMovie> _recentlyDownloaded = [];
  List<Map<String, dynamic>> _recentlyDownloadedShows = []; // Sonarr episodes
  List<Map<String, dynamic>> _airingNextShows = []; // Sonarr airing next
  List<RadarrMovie> _recommendedMovies = [];
  List<RadarrMovie> _missingMovies = [];
  List<RadarrMovie> _downloadingSoon = [];
  List<Map<String, dynamic>> _popularMovies = [];
  List<Map<String, dynamic>> _popularTVShows = [];
  List<Map<String, dynamic>> _trendingNewTVShows = [];
  List<Map<String, dynamic>> _mostAnticipatedShows = [];
  List<Map<String, dynamic>> _mostAnticipatedMovies = [];
  List<Map<String, dynamic>> _popularPeople = [];
  final Map<String, Map<String, dynamic>?> _traktRatingCache = {};
  bool _isLoading = true;
  String? _error;

  // Hero carousel state
  final PageController _moviesHeroPageController = PageController();
  final PageController _tvHeroPageController = PageController();
  Iterable<PageController> get _heroPageControllers =>
      [_moviesHeroPageController, _tvHeroPageController];
  int _currentHeroIndex = 0;
  String _trendingTimeWindow = 'day'; // 'day' or 'week'
  List<Map<String, dynamic>> _trendingItems = [];
  Timer? _autoScrollTimer;
  final Set<String> _precachedHeroBackdrops = {};
  final Map<String, ScrollController> _sectionScrollControllers = {};

  // Z Assistant navigation history
  String? _lastZAssistantStageId;

  // Library sync state
  bool _isSyncing = false;

  // Z Assistant Radarr/Sonarr settings
  int? _radarrQualityProfileId;
  String? _radarrQualityProfileName;
  String? _radarrRootFolder;
  bool _radarrSearchForMissing = true;
  int? _sonarrQualityProfileId;
  String? _sonarrQualityProfileName;
  String? _sonarrRootFolder;
  String? _sonarrMonitorType;
  String? _sonarrSeriesType;
  bool _sonarrSearchForMissing = true;
  bool _sonarrSearchForCutoffUnmet = false;

  // Z Assistant user selection
  List<_UserOption> _availableUsers = [];
  bool _loadingUsers = false;
  String? _selectedUser;
  StateSetter? _quickSetupModalSetState;

  bool get _showTitles =>
      ZagreusDatabase.DISCOVER_SHOW_TITLES.read() ?? true;

  // Deep Cuts future (cached to avoid refetching on rebuild)
  Future<DeepCutsResult>? _deepCutsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadTrendingTimeWindowSetting();
    _pageController = ZagPageController(initialPage: 0);
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });
    _loadRecentlyDownloaded();
    _loadRecentlyDownloadedShows();
    _loadRecommendedMovies();
    _loadMissingMovies();
    _loadDownloadingSoon();
    // Don't load popular movies or people here - will do it in didChangeDependencies
    _loadMockTrendingData();
    _startAutoScroll();
  }

  void _refreshQuickSetupModal() {
    _quickSetupModalSetState?.call(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load popular movies and people here where we can access Localizations
    _loadPopularMovies();
    _loadPopularTVShows();
    _loadTrendingNewTVShows();
    _loadMostAnticipatedShows();
    _loadMostAnticipatedMovies();
    _loadPopularPeople();
    _loadSonarrAiringNext();
    _syncDeepCutsIfNeeded();
  }

  Future<void> _syncDeepCutsIfNeeded() async {
    if (!ZagreusMega.isEnabled) return;

    try {
      final deepCutsService = DeepCutsService();
      final needsRegen = await deepCutsService.needsRegeneration();

      if (needsRegen) {
        ZagLogger().debug('Deep Cuts need regeneration - triggering...');
        // Fire and forget - don't await
        deepCutsService.syncIfNeeded();
      }
    } catch (e, stack) {
      ZagLogger().error('Deep Cuts sync check failed', e, stack);
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    for (final controller in _sectionScrollControllers.values) {
      controller.dispose();
    }
    _moviesHeroPageController.dispose();
    _tvHeroPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  ScrollController _sectionScrollController(String key) {
    return _sectionScrollControllers.putIfAbsent(
      key,
      () => ScrollController(),
    );
  }

  void _withHeroControllers(
    void Function(PageController controller) action,
  ) {
    for (final controller in _heroPageControllers) {
      if (controller.hasClients) {
        action(controller);
      }
    }
  }

  Future<void> _refreshSection({
    required String scrollKey,
    required Future<void> Function() loader,
    String? sectionLabel,
  }) async {
    if (sectionLabel != null) {
      showZagSnackBar(
        title: 'Refreshing',
        message: 'Updating $sectionLabel…',
        type: ZagSnackbarType.INFO,
        duration: const Duration(milliseconds: 1500),
      );
    }

    final controller = _sectionScrollControllers[scrollKey];
    final previousOffset =
        (controller != null && controller.hasClients) ? controller.offset : null;

    await loader();

    if (previousOffset == null || controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      final maxExtent = controller.position.maxScrollExtent;
      final maxAllowed = maxExtent.isFinite ? maxExtent : previousOffset;
      final clampedOffset = previousOffset.clamp(0.0, maxAllowed).toDouble();
      controller.jumpTo(clampedOffset);
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_trendingItems.isEmpty) return;
      final nextIndex = (_currentHeroIndex + 1) % _trendingItems.length;
      _withHeroControllers((controller) {
        controller.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _restartAutoScroll() {
    _stopAutoScroll();
    _startAutoScroll();
  }

  void _loadTrendingTimeWindowSetting() {
    final saved = ZagreusDatabase.DISCOVER_TRENDING_TIME_WINDOW.read();
    if (saved == 'week' || saved == 'day') {
      _trendingTimeWindow = saved;
    } else {
      _trendingTimeWindow = 'day';
    }
  }

  void _loadMockTrendingData() {
    _loadTrendingData();
  }

  Future<void> _loadTrendingData() async {
    try {
      final items = await TMDBApi.getTrending(
        mediaType: 'all', // Can be 'movie', 'tv', or 'all'
        timeWindow: _trendingTimeWindow,
      );

      // Check against Radarr library if available
      if (mounted) {
        final radarrState = context.read<RadarrState>();
        if (radarrState.enabled && radarrState.movies != null) {
          final movies = await radarrState.movies!;
          for (final item in items) {
            if (item['mediaType'] == 'movie') {
              final tmdbId = item['tmdbId'] as int;
              item['inLibrary'] = movies.any((m) => m.tmdbId == tmdbId);
            }
          }
        }

        // Check against Sonarr library if available
        final sonarrState = context.read<SonarrState>();
        if (sonarrState.enabled && sonarrState.api != null) {
          try {
            final sonarrSeries = await sonarrState.api!.series.getAll();
            for (final item in items) {
              if (item['mediaType'] == 'tv') {
                final title = item['title'] as String;
                // Check if this show is in Sonarr library by title match
                final inLibrary = sonarrSeries.any((series) {
                  return series.title?.toLowerCase() == title.toLowerCase();
                });
                item['inLibrary'] = inLibrary;
              }
            }
          } catch (e) {
            print('📺 Error checking Sonarr library for trending: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _trendingItems = items;
          _precachedHeroBackdrops.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _precacheHeroImage(_currentHeroIndex);
          _precacheHeroImage(_currentHeroIndex + 1);
          _precacheHeroImage(_currentHeroIndex + 2);
        });
      }
    } catch (e) {
      print('Failed to load trending: $e');
      // Falls back to mock data in the API
    }
  }

  void _precacheHeroImage(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _trendingItems.length) return;
    final url = _trendingItems[index]['backdrop'] as String?;
    if (url == null || url.isEmpty) return;
    if (_precachedHeroBackdrops.contains(url)) return;
    _precachedHeroBackdrops.add(url);
    precacheImage(NetworkImage(url), context);
  }

  Future<void> _loadRecentlyDownloaded({bool showGlobalLoader = true}) async {
    if (showGlobalLoader) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }

    try {
      // Check if Radarr is enabled first
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        // If Radarr is not enabled, just use empty list
        setState(() {
          _recentlyDownloaded = [];
          if (showGlobalLoader) _isLoading = false;
        });
        return;
      }

      final api = radarrState.api;
      if (api == null) {
        // If API not configured, use empty list
        setState(() {
          _recentlyDownloaded = [];
          if (showGlobalLoader) _isLoading = false;
        });
        return;
      }

      // Fetch history
      final history = await api.history.get(
        pageSize: 50,
        sortDirection: RadarrSortDirection.DESCENDING,
        sortKey: RadarrHistorySortKey.DATE,
      );

      // Filter only downloaded items and get unique movie IDs
      final downloadedRecords = history.records?.where((record) {
            return record.eventType == RadarrEventType.DOWNLOAD_FOLDER_IMPORTED;
          }).toList() ??
          [];

      // Get unique movie IDs from history
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
      for (final movieId in movieIds.take(_discoverFullPageLimit)) {
        final movie = allMovies.firstWhere(
          (m) => m.id == movieId,
          orElse: () => RadarrMovie(),
        );
        if (movie.id != null) {
          downloadedMovies.add(movie);
        }
      }

      setState(() {
        _recentlyDownloaded = downloadedMovies;
        if (showGlobalLoader) _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        if (showGlobalLoader) _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendedMovies() async {
    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        // If Radarr not enabled, use empty list
        setState(() {
          _recommendedMovies = [];
        });
        return;
      }

      final api = radarrState.api;
      if (api == null) {
        return;
      }

      // Fetch recommended movies from import lists
      final recommendedMovies = await api.importList.getMovies(
        includeRecommendations: true,
      );

      // Remove duplicates and limit
      final Set<int> tmdbIds = {};
      final uniqueMovies = <RadarrMovie>[];
      for (final movie in recommendedMovies) {
        if (movie.tmdbId != null && !tmdbIds.contains(movie.tmdbId)) {
          tmdbIds.add(movie.tmdbId!);
          uniqueMovies.add(movie);
        }
      }

      setState(() {
        _recommendedMovies = uniqueMovies.take(_discoverFullPageLimit).toList();
      });
    } catch (e) {
      // Silently fail - recommendations are optional
      print('Failed to load recommendations: $e');
    }
  }

  Future<void> _loadMissingMovies() async {
    try {
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        // If Radarr not enabled, use empty list
        setState(() {
          _missingMovies = [];
        });
        return;
      }

      // Fetch movies if not already cached
      if (radarrState.movies == null) {
        radarrState.fetchMovies();
      }

      // Get missing movies from state
      if (radarrState.missing != null) {
        final missingMovies = await radarrState.missing!;
        setState(() {
          _missingMovies = missingMovies.take(_discoverFullPageLimit).toList();
        });
      }
    } catch (e) {
      // Silently fail - missing movies are optional
      print('Failed to load missing movies: $e');
    }
  }

  Future<void> _loadDownloadingSoon() async {
    try {
      print('📅 [DOWNLOADING SOON] Starting to load...');
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        print('📅 [DOWNLOADING SOON] Radarr not enabled, using empty list');
        setState(() {
          _downloadingSoon = [];
        });
        return;
      }

      // Fetch movies if not already cached
      if (radarrState.movies == null) {
        print('📅 [DOWNLOADING SOON] Movies cache is null, fetching...');
        radarrState.fetchMovies();
      }

      // Wait for movies to load
      print('📅 [DOWNLOADING SOON] Waiting for movies to load...');
      final allMovies = await radarrState.movies!;
      print(
          '📅 [DOWNLOADING SOON] Loaded ${allMovies.length} total movies from Radarr');

      final downloadingSoon = <RadarrMovie>[];
      final now = DateTime.now();
      const lookAheadDays = 28;

      int monitoredCount = 0;
      int notDownloadedCount = 0;
      int monitoredNotDownloaded = 0;

      for (final movie in allMovies) {
        final isMonitored = movie.monitored == true;
        final hasFile = movie.hasFile == true;

        if (isMonitored) monitoredCount++;
        if (!hasFile) notDownloadedCount++;
        if (isMonitored && !hasFile) monitoredNotDownloaded++;

        // Skip if not monitored or already downloaded
        if (!isMonitored || hasFile) {
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

          print('📅 [DOWNLOADING SOON] Movie "${movie.title}":');
          print('📅   - Digital: ${movie.digitalRelease}');
          print('📅   - Physical: ${movie.physicalRelease}');
          print('📅   - Days until: $daysUntil');

          // Check if within look-ahead window
          if (daysUntil >= 0 && daysUntil <= lookAheadDays) {
            downloadingSoon.add(movie);
            print(
                '📅 [DOWNLOADING SOON] ✅ Added "${movie.title}" - releases in $daysUntil days');
          }
        }
      }

      print('📅 [DOWNLOADING SOON] Summary:');
      print('📅 [DOWNLOADING SOON]   Total movies: ${allMovies.length}');
      print('📅 [DOWNLOADING SOON]   Monitored: $monitoredCount');
      print('📅 [DOWNLOADING SOON]   Not downloaded: $notDownloadedCount');
      print(
          '📅 [DOWNLOADING SOON]   Monitored & not downloaded: $monitoredNotDownloaded');
      print(
          '📅 [DOWNLOADING SOON]   Downloading soon: ${downloadingSoon.length}');

      // Sort by release date (closest first)
      downloadingSoon.sort((a, b) {
        final aDate = a.digitalRelease ??
            a.physicalRelease ??
            (a.inCinemas?.add(const Duration(days: 90)));
        final bDate = b.digitalRelease ??
            b.physicalRelease ??
            (b.inCinemas?.add(const Duration(days: 90)));
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      setState(() {
        _downloadingSoon =
            downloadingSoon.take(_discoverFullPageLimit).toList();
        print(
            '📅 [DOWNLOADING SOON] Set ${_downloadingSoon.length} movies in state');
      });
    } catch (e) {
      print('📅 [DOWNLOADING SOON] ERROR: $e');
      print('📅 [DOWNLOADING SOON] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _loadPopularMovies() async {
    print('🎬 Loading popular movies...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';
      print('🎬 Using region: $region');

      final movies = await TMDBApi.getPopularMovies(region: region);
      print('🎬 Got ${movies.length} popular movies from TMDB');

      // Check against Radarr library if available
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final radarrMovies = await radarrState.movies!;
        for (final movie in movies) {
          final tmdbId = movie['tmdbId'] as int;
          movie['inLibrary'] = radarrMovies.any((m) => m.tmdbId == tmdbId);
        }
      }

      if (mounted) {
        setState(() {
          _popularMovies =
              movies.take(10).toList(); // Limit to 10 for the section
        });
        print('🎬 Set ${_popularMovies.length} popular movies in state');
      }
    } catch (e) {
      print('❌ Error loading popular movies: $e');
    }
  }

  Future<void> _loadRecentlyDownloadedShows() async {
    try {
      final sonarrState = context.read<SonarrState>();
      if (!sonarrState.enabled || sonarrState.api == null) {
        // Use empty list if Sonarr is not enabled
        setState(() {
          _recentlyDownloadedShows = [];
        });
        return;
      }

      final api = sonarrState.api!;

      // Fetch history sorted by date descending
      final history = await api.history.get(
        page: 1,
        pageSize: 100,
        sortKey: SonarrHistorySortKey.DATE,
        sortDirection: SonarrSortDirection.DESCENDING,
        includeEpisode: true,
        includeSeries: true,
      );

      // Filter to only downloadFolderImported events and dedupe by episodeId
      final downloadedRecords = <SonarrHistoryRecord>[];
      final seenEpisodeIds = <int>{};

      for (final record in history.records ?? []) {
        if (record.eventType == SonarrEventType.DOWNLOAD_FOLDER_IMPORTED &&
            record.episodeId != null &&
            !seenEpisodeIds.contains(record.episodeId)) {
          seenEpisodeIds.add(record.episodeId!);
          downloadedRecords.add(record);
          if (downloadedRecords.length >= 10) break; // Limit to 10 items
        }
      }

      // Map to UI format
      final shows = <Map<String, dynamic>>[];
      for (final record in downloadedRecords) {
        final episode = record.episode;
        final series = record.series;

        if (episode != null && series != null) {
          // Get fanart or poster image
          String? imageUrl;
          for (final image in series.images ?? []) {
            if (image.coverType == 'fanart') {
              imageUrl = image.remoteUrl ?? image.url;
              break;
            }
          }
          // Fallback to poster if no fanart
          if (imageUrl == null) {
            for (final image in series.images ?? []) {
              if (image.coverType == 'poster') {
                imageUrl = image.remoteUrl ?? image.url;
                break;
              }
            }
          }

          double? sizeGb;
          final dynamic rawSize = record.data?['size'];
          if (rawSize != null) {
            if (rawSize is num) {
              sizeGb = rawSize / (1024 * 1024 * 1024);
            } else if (rawSize is String) {
              final parsed = num.tryParse(rawSize);
              if (parsed != null) {
                sizeGb = parsed / (1024 * 1024 * 1024);
              }
            }
          }

          shows.add({
            'seriesTitle': series.title ?? 'Unknown Series',
            'episodeTitle': episode.title ?? 'Episode ${episode.episodeNumber}',
            'seasonNumber': episode.seasonNumber ?? 0,
            'episodeNumber': episode.episodeNumber ?? 0,
            'network': 'Downloaded',
            'thumbnail': imageUrl,
            'airDateUtc': episode.airDateUtc,
            'seriesId': series.id,
            'episodeId': episode.id,
            'sizeGb': sizeGb,
          });
        }
      }

      setState(() {
        _recentlyDownloadedShows = shows;
      });
    } catch (e) {
      print('Error loading Sonarr history: $e');
      // Fallback to empty list on error
      setState(() {
        _recentlyDownloadedShows = [];
      });
    }
  }

  Future<void> _loadSonarrAiringNext() async {
    try {
      final sonarrState = context.read<SonarrState>();
      if (!sonarrState.enabled || sonarrState.api == null) {
        setState(() {
          _airingNextShows = [];
        });
        return;
      }

      final api = sonarrState.api!;

      // Get episodes airing in the next 7 days
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 14)); // Look 14 days ahead

      final calendar = await api.calendar.get(
        start: now,
        end: endDate,
        unmonitored: false, // Only get monitored episodes
        includeSeries: true,
        includeEpisodeFile: true,
      );

      // Filter to only monitored episodes that haven't aired yet
      final upcomingEpisodes = calendar.where((episode) {
        return episode.monitored == true &&
            episode.airDateUtc != null &&
            episode.airDateUtc!.isAfter(now);
      }).toList();

      // Sort by air date
      upcomingEpisodes.sort((a, b) => a.airDateUtc!.compareTo(b.airDateUtc!));

      // Map to UI format
      final shows = <Map<String, dynamic>>[];
      for (final episode in upcomingEpisodes.take(10)) {
        // Limit to 10 items
        final series = episode.series;

        if (series != null) {
          // Get fanart or poster image
          String? imageUrl;
          for (final image in series.images ?? []) {
            if (image.coverType == 'fanart') {
              imageUrl = image.remoteUrl ?? image.url;
              break;
            }
          }
          // Fallback to poster if no fanart
          if (imageUrl == null) {
            for (final image in series.images ?? []) {
              if (image.coverType == 'poster') {
                imageUrl = image.remoteUrl ?? image.url;
                break;
              }
            }
          }

          shows.add({
            'seriesTitle': series.title ?? 'Unknown Series',
            'episodeTitle': episode.title ?? 'Episode ${episode.episodeNumber}',
            'seasonNumber': episode.seasonNumber ?? 0,
            'episodeNumber': episode.episodeNumber ?? 0,
            'network': series.network ?? 'Network',
            'thumbnail': imageUrl,
            'airDateUtc': episode.airDateUtc,
            'seriesId': series.id,
            'episodeId': episode.id,
            'hasFile': episode.hasFile ?? false,
          });
        }
      }

      setState(() {
        _airingNextShows = shows;
      });
    } catch (e) {
      print('Error loading Sonarr airing next: $e');
      setState(() {
        _airingNextShows = [];
      });
    }
  }

  String _formatAiringTime(DateTime? airDateUtc, String? network) {
    if (airDateUtc == null) return '';

    // Convert UTC to local time
    final localTime = airDateUtc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final episodeDay = DateTime(localTime.year, localTime.month, localTime.day);

    String dayLabel;
    if (episodeDay == today) {
      dayLabel = 'Today';
    } else if (episodeDay == tomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      // Format as "Mon, Jan 15"
      final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
      dayLabel =
          '${weekdays[localTime.weekday % 7]}, ${months[localTime.month - 1]} ${localTime.day}';
    }

    // Format time as "3:00 PM"
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    // Truncate network name if too long
    final networkName = network ?? '';
    final truncatedNetwork = networkName.length > 12
        ? '${networkName.substring(0, 12)}...'
        : networkName;

    return '$dayLabel • $displayHour:$minute $period${truncatedNetwork.isNotEmpty ? ' on $truncatedNetwork' : ''}';
  }

  Future<void> _loadPopularTVShows() async {
    print('📺 Loading popular TV shows...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';
      print('📺 Using region: $region');

      final shows = await TMDBApi.getPopularTVShows(region: region);
      print('📺 Got ${shows.length} popular TV shows from TMDB');

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          final sonarrSeries = await sonarrState.api!.series.getAll();
          print('📺 Checking against ${sonarrSeries.length} Sonarr series');

          for (final show in shows) {
            final tmdbId = show['tmdbId'] as int;
            // Check if this show is in Sonarr library by TMDB ID
            final inLibrary = sonarrSeries.any((series) {
              // Sonarr uses TVDB ID primarily, but we can check if any series matches
              // For now, we'll use a simple name match as fallback
              // In production, you'd want to use a proper TMDB to TVDB mapping
              return series.title?.toLowerCase() ==
                  (show['title'] as String).toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final series = sonarrSeries.firstWhere(
                (s) =>
                    s.title?.toLowerCase() ==
                    (show['title'] as String).toLowerCase(),
              );
              show['serviceItemId'] = series.id;
            }
          }
        } catch (e) {
          print('📺 Error checking Sonarr library: $e');
        }
      }

      if (mounted) {
        setState(() {
          _popularTVShows =
              shows.take(10).toList(); // Limit to 10 for the section
        });
        print('📺 Set ${_popularTVShows.length} popular TV shows in state');
      }
    } catch (e) {
      print('❌ Error loading popular TV shows: $e');
    }
  }

  Future<void> _loadTrendingNewTVShows() async {
    print('🆕 Loading trending new TV shows...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';
      print('🆕 Using region: $region');

      final shows = await TMDBApi.getTrendingNewTVShows(region: region);
      print('🆕 Got ${shows.length} trending new TV shows from TMDB');

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          final sonarrSeries = await sonarrState.api!.series.getAll();
          print('🆕 Checking against ${sonarrSeries.length} Sonarr series');

          for (final show in shows) {
            final tmdbId = show['tmdbId'] as int;
            // Check if this show is in Sonarr library by TMDB ID
            final inLibrary = sonarrSeries.any((series) {
              // Using title match as fallback for now
              return series.title?.toLowerCase() ==
                  (show['title'] as String).toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final series = sonarrSeries.firstWhere(
                (s) =>
                    s.title?.toLowerCase() ==
                    (show['title'] as String).toLowerCase(),
              );
              show['serviceItemId'] = series.id;
            }
          }
        } catch (e) {
          print('🆕 Error checking Sonarr library: $e');
        }
      }

      if (mounted) {
        setState(() {
          _trendingNewTVShows =
              shows.take(10).toList(); // Limit to 10 for the section
        });
        print(
            '🆕 Set ${_trendingNewTVShows.length} trending new TV shows in state');
      }
    } catch (e) {
      print('❌ Error loading trending new TV shows: $e');
    }
  }

  Future<void> _loadMostAnticipatedShows() async {
    print('🎯 Loading most anticipated shows from Trakt...');
    try {
      // Use the real Trakt API
      final shows = await TraktApi.getAnticipatedShows(page: 1, limit: 10);
      print('🎯 Got ${shows.length} most anticipated shows from Trakt');

      // Enrich with TMDB poster images if we have TMDB IDs
      int showIndex = 0;
      for (final show in shows) {
        final tmdbId = show['tmdbId'] as int?;
        if (tmdbId != null) {
          // Fetch poster from TMDB
          final tmdbDetails = await TMDBApi.getTVShowDetails(tmdbId);
          if (tmdbDetails != null) {
            show['poster'] =
                TMDBApi.getImageUrl(tmdbDetails['poster_path'], size: 'w500');
            show['backdrop'] =
                TMDBApi.getImageUrl(tmdbDetails['backdrop_path']);
            // Use TMDB overview if Trakt doesn't have one
            if (show['overview'] == null ||
                (show['overview'] as String).isEmpty) {
              show['overview'] = tmdbDetails['overview'];
            }
          }
        }
        if (showIndex < _discoverPreviewLimit) {
          await _ensureTraktRating(show, isMovie: false);
        }
        showIndex++;
      }

      // Check against Sonarr library if available
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.api != null) {
        try {
          final sonarrSeries = await sonarrState.api!.series.getAll();
          print('🎯 Checking against ${sonarrSeries.length} Sonarr series');

          for (final show in shows) {
            final tvdbId = show['tvdbId'] as int?;
            final title = show['title'] as String;

            // Check if this show is in Sonarr library by TVDB ID or title
            final inLibrary = sonarrSeries.any((series) {
              if (tvdbId != null && series.tvdbId == tvdbId) {
                return true;
              }
              return series.title?.toLowerCase() == title.toLowerCase();
            });
            show['inLibrary'] = inLibrary;

            if (inLibrary) {
              final series = sonarrSeries.firstWhere(
                (s) =>
                    (tvdbId != null && s.tvdbId == tvdbId) ||
                    s.title?.toLowerCase() == title.toLowerCase(),
              );
              show['serviceItemId'] = series.id;
            }
          }
        } catch (e) {
          print('🎯 Error checking Sonarr library: $e');
        }
      }

      if (mounted) {
        setState(() {
          _mostAnticipatedShows =
              shows.take(10).toList(); // Limit to 10 for the section
        });
        print(
            '🎯 Set ${_mostAnticipatedShows.length} most anticipated shows in state');
      }
    } catch (e) {
      print('❌ Error loading most anticipated shows: $e');
    }
  }

  Future<void> _loadMostAnticipatedMovies() async {
    print('🎯 Loading most anticipated movies from Trakt...');
    try {
      final movies = await TraktApi.getAnticipatedMovies(page: 1, limit: 20);
      final radarrState = context.read<RadarrState>();
      List<RadarrMovie>? radarrMovies;
      if (radarrState.enabled) {
        if (radarrState.movies == null) {
          radarrState.fetchMovies();
        }
        if (radarrState.movies != null) {
          radarrMovies = await radarrState.movies!;
        }
      }

      int movieIndex = 0;
      for (final movie in movies) {
        final tmdbId = movie['tmdbId'] as int?;
        if (tmdbId != null) {
          final details = await TMDBApi.getMovieDetails(tmdbId);
          if (details != null) {
            movie['poster'] = TMDBApi.getImageUrl(
              details['poster_path'],
              size: 'w500',
            );
            movie['backdrop'] = TMDBApi.getImageUrl(details['backdrop_path']);
            movie['overview'] ??= details['overview'];
            movie['releaseDate'] ??= details['release_date'];
          }
        }
        if (movieIndex < 12) {
          await _ensureTraktRating(movie, isMovie: true);
        }
        movieIndex++;

        movie['inLibrary'] = false;
        if (radarrMovies != null && radarrMovies.isNotEmpty) {
          for (final radarrMovie in radarrMovies) {
            final matchesTmdb = tmdbId != null && radarrMovie.tmdbId == tmdbId;
            final matchesImdb = radarrMovie.imdbId != null &&
                radarrMovie.imdbId == (movie['imdbId'] as String?);
            if (matchesTmdb || matchesImdb) {
              movie['inLibrary'] = true;
              movie['serviceItemId'] = radarrMovie.id;
              break;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _mostAnticipatedMovies = movies.take(12).toList();
        });
        print(
            '🎯 Set ${_mostAnticipatedMovies.length} most anticipated movies in state');
      }
    } catch (e) {
      print('❌ Error loading most anticipated movies: $e');
    }
  }

  Future<void> _ensureTraktRating(
    Map<String, dynamic> item, {
    required bool isMovie,
  }) async {
    final currentRating = (item['rating'] as num?)?.toDouble();
    if (currentRating != null && currentRating > 0) {
      item['rating'] = currentRating;
      return;
    }

    final slug = item['slug'] as String?;
    final traktId = item['traktId'];
    final imdbId = item['imdbId'] as String?;
    final identifier = slug ?? traktId?.toString() ?? imdbId;

    if (identifier == null || identifier.isEmpty) {
      item['rating'] = currentRating ?? 0.0;
      return;
    }

    final cacheKey = '${isMovie ? 'movie' : 'show'}:$identifier';
    Map<String, dynamic>? ratingData = _traktRatingCache[cacheKey];
    if (ratingData == null) {
      ratingData = isMovie
          ? await TraktApi.getMovieRatings(identifier)
          : await TraktApi.getShowRatings(identifier);
      if (ratingData != null) {
        _traktRatingCache[cacheKey] = ratingData;
      }
    }

    if (ratingData != null) {
      final rating = (ratingData['rating'] as num?)?.toDouble();
      final votes = (ratingData['votes'] as num?)?.toInt();
      if (rating != null) {
        item['rating'] = rating;
      }
      if (votes != null) {
        item['votes'] = votes;
      }
    }

    item['rating'] = (item['rating'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> _loadPopularPeople() async {
    print('👥 Loading popular people...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final people = await TMDBApi.getPopularPeople(region: region);
      print('👥 Got ${people.length} popular people from TMDB');

      if (mounted) {
        setState(() {
          _popularPeople =
              people.take(20).toList(); // Show 20 people in the row
        });
        print('👥 Set ${_popularPeople.length} popular people in state');
      }
    } catch (e) {
      print('❌ Error loading popular people: $e');
    }
  }

  bool get _showLegacyModules =>
      ZagreusDatabase.SHOW_LEGACY_MODULES_TAB.read();
  bool get _showAgentTab => ZagreusDatabase.SHOW_AGENT_TAB.read();

  @override
  Widget build(BuildContext context) {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: const [
        ZagreusDatabase.SHOW_LEGACY_MODULES_TAB,
        ZagreusDatabase.SHOW_AGENT_TAB,
      ],
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        module: ZagModule.DISCOVER,
        drawer: ZagDrawer(page: ZagModule.DISCOVER.key),
        appBar: ZagAppBar(
          title: _isSearchActive ? 'Search' : (_isAgentActive ? 'Z Agent' : ZagModule.DISCOVER.title),
          useDrawer: true,
          actions: _buildAppBarActions(),
        ),
        body: _body(),
        bottomNavigationBar: (_isSearchActive || _isAgentActive)
            ? null
            : _DiscoverNavigationBar(
                pageController: _pageController,
                showLegacyModules: _showLegacyModules,
                showAgentTab: _showAgentTab,
              ),
      ),
    );
  }

  Widget _body() {
    final enableLegacyModules = _showLegacyModules;
    final showAgentTab = _showAgentTab;
    final tabs = ZagPageView(
      key: ValueKey('discover_tabs_${enableLegacyModules}_$showAgentTab'),
      controller: _pageController,
      children: [
        if (enableLegacyModules) _modulesPage(),
        _moviesPage(),
        _tvShowsPage(),
        _calendarTab(),
        _serverTab(),
      ],
    );

    if (!_isSearchActive && !_isAgentActive) return tabs;

    return Stack(
      children: [
        tabs,
        if (_isSearchActive)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: KeyedSubtree(
                key: const ValueKey('discover_search'),
                child: _searchPage(),
              ),
            ),
          ),
        if (_isAgentActive)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: KeyedSubtree(
                key: const ValueKey('discover_agent'),
                child: const ZChatPage(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitleRow({
    required BuildContext context,
    required IconData leadingIcon,
    required Color leadingIconColor,
    required String moduleLabel,
    required String title,
    Color? moduleLabelColor,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    bool showArrow = false,
    IconData trailingIcon = Icons.arrow_forward_ios,
    Color? trailingColor,
    double trailingSize = 16,
    TextStyle? titleStyle,
  }) {
    final theme = Theme.of(context);
    final defaultTitleColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          fontSize: _moduleSectionTitleFontSize,
          fontWeight: FontWeight.bold,
          color: defaultTitleColor,
        );
    final effectiveModuleLabelColor = moduleLabelColor ?? leadingIconColor;
    final shouldShowArrow = showArrow || onTap != null;
    final arrowColor = trailingColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
            .withOpacity(0.5);

    return Padding(
      padding: padding ?? _moduleSectionTitlePadding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  leadingIcon,
                  color: leadingIconColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  moduleLabel,
                  style: TextStyle(
                    fontSize: _moduleSectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: effectiveModuleLabelColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: effectiveTitleStyle,
                  ),
                ),
                if (shouldShowArrow)
                  Icon(
                    trailingIcon,
                    size: trailingSize,
                    color: arrowColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildAppBarActions() {
    final enableLegacyModules = _showLegacyModules;
    final showAgentTab = _showAgentTab;
    final moviesTabIndex = enableLegacyModules ? 1 : 0;
    final showsTabIndex = enableLegacyModules ? 2 : 1;
    final calendarIndex = enableLegacyModules ? 3 : 2;
    final serverIndex = enableLegacyModules ? 4 : 3;

    if (_isSearchActive) {
      return [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close Search',
          onPressed: _closeSearchOverlay,
        ),
      ];
    }

    if (_isAgentActive) {
      return [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _showZAssistantSettings,
          tooltip: 'Z Assistant Settings',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showZAgentQuickSetup,
          tooltip: 'Z Agent setup',
        ),
        if (_lastZAssistantStageId != null)
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToLastZAssistantResults,
            tooltip: 'Return to Z Assistant Results',
          ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close Agent',
          onPressed: _closeAgentOverlay,
        ),
      ];
    }

    if (_currentPageIndex == calendarIndex) {
      return [
        SwitchViewAction(
          pageController: _pageController,
          calendarPageIndex: calendarIndex,
        ),
      ];
    }

    final actions = <Widget>[];
    if (_currentPageIndex == moviesTabIndex ||
        _currentPageIndex == showsTabIndex ||
        _currentPageIndex == serverIndex) {
      if (showAgentTab) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Z Agent',
            onPressed: _openAgentOverlay,
          ),
        );
      }
      actions.add(
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: _openSearchOverlay,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  Widget _moviesPage() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6688FF)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load recently downloaded',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecentlyDownloaded,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6688FF),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloaded,
      child: ListView(
      controller: _DiscoverNavigationBar.moviesScrollController,
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel
          _heroCarousel(
            controller: _moviesHeroPageController,
            storageKey: 'discoverHeroCarouselMovies',
          ),
          // Content sections in custom order
          ..._buildMovieSections(),
          _discoverSectionsButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildMovieSections() {
    // Default section order
    const defaultOrder = [
      'recently_downloaded',
      'recommended',
      'missing',
      'downloading_soon',
      'popular_movies',
      'most_anticipated_movies',
      'popular_people',
      'deep_cuts',
    ];

    // Get saved order or use default
    final savedOrder =
        ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    final sectionOrder =
        savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;
    if (!sectionOrder.contains('most_anticipated_movies')) {
      final popularIndex = sectionOrder.indexOf('popular_movies');
      final insertIndex =
          popularIndex == -1 ? sectionOrder.length : popularIndex + 1;
      sectionOrder.insert(insertIndex, 'most_anticipated_movies');
    }

    // Map of section builders
    final sectionBuilders = <String, Widget Function()>{
      'recently_downloaded': () => _recentlyDownloaded.isNotEmpty
          ? Column(children: [
              _recentlyDownloadedSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
      'recommended': () => Column(children: [
            _recommendedMoviesSection(),
            if (_showTitles) const SizedBox(height: 4)
          ]),
      'missing': () => _missingMovies.isNotEmpty
          ? Column(children: [
              _missingMoviesSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
      'downloading_soon': () => Column(children: [
            _downloadingSoonSection(),
            if (_showTitles) const SizedBox(height: 4)
          ]),
      'popular_movies': () => Column(children: [
            _popularMoviesSection(),
            if (_showTitles) const SizedBox(height: 4)
          ]),
      'most_anticipated_movies': () =>
          _mostAnticipatedMoviesSection(), // Works even if empty
      'popular_people': () => Column(children: [
            _popularPeopleSection(),
            if (_showTitles) const SizedBox(height: 4)
          ]),
      'deep_cuts': () => ZagreusMega.isEnabled
          ? Column(children: [
              _deepCutsSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
    };

    // Build sections in saved order
    final sections = <Widget>[];
    for (final sectionKey in sectionOrder) {
      final builder = sectionBuilders[sectionKey];
      if (builder != null) {
        sections.add(builder());
      }
    }
    return sections;
  }

  Widget _modulesPage() {
    return ModulesPage(
      key: ValueKey(
        'dashboard_modules_${ZagreusDatabase.ENABLED_PROFILE.read()}',
      ),
      controller: _DiscoverNavigationBar.modulesScrollController,
    );
  }

  Widget _tvShowsPage() {
    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloadedShows,
      child: ListView(
      controller: _DiscoverNavigationBar.showsScrollController,
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel (could be TV shows specific)
          _heroCarousel(
            controller: _tvHeroPageController,
            storageKey: 'discoverHeroCarouselTv',
          ),
          // TV shows sections in custom order
          ..._buildTVSections(),
          const SizedBox(height: 16),
          _discoverSectionsButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildTVSections() {
    // Default section order
    const defaultOrder = [
      'recently_downloaded_shows',
      'airing_next',
      'popular_tv_shows',
      'trending_new_tv_shows',
      'most_anticipated',
    ];

    // Get saved order or use default
    final savedOrder = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;
    final sectionOrder =
        savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

    // Map of section builders
    final sectionBuilders = <String, Widget Function()>{
      'recently_downloaded_shows': () => _recentlyDownloadedShows.isNotEmpty
          ? _recentlyDownloadedShowsSection()
          : const SizedBox.shrink(),
      'airing_next': () => _airingNextSection(),
      'popular_tv_shows': () => Column(children: [
            _popularTVShowsSection(),
            if (_showTitles) const SizedBox(height: 12)
          ]),
      'trending_new_tv_shows': () => Column(children: [
            _trendingNewTVShowsSection(),
            if (_showTitles) const SizedBox(height: 12)
          ]),
      'most_anticipated': () => _mostAnticipatedShowsSection(),
    };

    // Build sections in saved order
    final sections = <Widget>[];
    for (final sectionKey in sectionOrder) {
      final builder = sectionBuilders[sectionKey];
      if (builder != null) {
        sections.add(builder());
      }
    }
    return sections;
  }

  Widget _discoverSectionsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
        vertical: 8,
      ),
      child: ZagButton(
        type: ZagButtonType.TEXT,
        text: 'Edit Sections',
        icon: Icons.tune_rounded,
        color: ZagColours.currentAccent,
        onTap: _openDiscoverSectionsEditor,
      ),
    );
  }

  Future<void> _openDiscoverSectionsEditor() async {
    final updated = await showDashboardSectionsEditorSheet(context);
    if (updated == true && mounted) {
      setState(() {
        _loadTrendingTimeWindowSetting();
        _currentHeroIndex = 0;
      });
      _withHeroControllers((controller) => controller.jumpToPage(0));
      _loadTrendingData();
      _restartAutoScroll();
    }
  }

  void _openSearchOverlay() {
    if (_isSearchActive) return;
    setState(() {
      _isSearchActive = true;
      _lastNonSearchPageIndex = _currentPageIndex;
    });
  }

  void _closeSearchOverlay() {
    if (!_isSearchActive) return;
    setState(() {
      _isSearchActive = false;
      _currentPageIndex = _lastNonSearchPageIndex;
    });
    FocusScope.of(context).unfocus();
  }

  void _openAgentOverlay() {
    if (_isAgentActive) return;
    setState(() {
      _isAgentActive = true;
    });
  }

  void _closeAgentOverlay() {
    if (!_isAgentActive) return;
    setState(() {
      _isAgentActive = false;
    });
    FocusScope.of(context).unfocus();
  }

  Widget _calendarTab() {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => CalendarPage(
        key: ValueKey(
          'discover_calendar_${ZagreusDatabase.ENABLED_PROFILE.read()}',
        ),
      ),
    );
  }

  Widget _serverTab() {
    return _ServerPage();
  }

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  // Z Assistant state
  bool _isAskingZAssistant = false;

  Widget _searchPage() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search movies, TV shows, and people...',
              hintStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ZagColours.currentAccent,
                  width: 2,
                ),
              ),
            ),
            onChanged: (query) {
              // Debounce search
              _searchDebounce?.cancel();
              if (query.isEmpty) {
                setState(() {
                  _searchResults.clear();
                });
                return;
              }
              _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                _performSearch(query);
              });
            },
          ),
        ),
        // Search results
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: _isSearching
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ZagColours.currentAccent),
                    ),
                  )
                : _searchResults.isEmpty
                    ? _searchController.text.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 60,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Search for movies, TV shows, and people',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 60,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                    : _buildSearchResults(),
          ),
        ),
      ],
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      print('🔍 Searching for: $query');
      final tmdbApi = TMDBApi();
      List<Map<String, dynamic>> results = await tmdbApi.searchMulti(query);

      if (results.isNotEmpty) {
        final indexedResults = results.asMap().entries.toList();

        String normalizeText(String value) => value
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        String stripLeadingArticles(String value) {
          final lower = value;
          for (final article in ['the ', 'a ', 'an ']) {
            if (lower.startsWith(article)) {
              return lower.substring(article.length);
            }
          }
          return lower;
        }

        String singularize(String token) {
          if (token.length <= 3) return token;
          if (token.endsWith('ies')) {
            return '${token.substring(0, token.length - 3)}y';
          }
          if (token.endsWith('ves')) {
            return '${token.substring(0, token.length - 3)}f';
          }
          if (token.endsWith('es') && !token.endsWith('ses')) {
            return token.substring(0, token.length - 2);
          }
          if (token.endsWith('s') && !token.endsWith('ss')) {
            return token.substring(0, token.length - 1);
          }
          return token;
        }

        Set<String> tokenize(String value) {
          final normalized = normalizeText(value);
          if (normalized.isEmpty) return {};
          return normalized
              .split(' ')
              .where((token) => token.isNotEmpty)
              .map(singularize)
              .toSet();
        }

        final normalizedQuery = normalizeText(query);
        final strippedQuery = stripLeadingArticles(normalizedQuery);
        final queryTokens = tokenize(query);

        int? extractYear(Map<String, dynamic> item) {
          final dateString =
              (item['release_date'] ?? item['first_air_date']) as String?;
          if (dateString == null || dateString.isEmpty) return null;
          final yearPart = dateString.split('-').first;
          return int.tryParse(yearPart);
        }

        double mediaPriority(Map<String, dynamic> item) {
          final mediaType = item['media_type'] as String?;
          switch (mediaType) {
            case 'movie':
            case 'tv':
              return 1.0;
            case 'collection':
              return 0.8;
            case 'person':
              return 0.5;
            default:
              return 0.4;
          }
        }

        final maxPopularity = indexedResults.fold<double>(
          0,
          (current, entry) {
            final value = (entry.value['popularity'] as num?)?.toDouble() ?? 0;
            return math.max(current, value);
          },
        );

        final maxVoteLog = indexedResults.fold<double>(
          0,
          (current, entry) {
            final votes = (entry.value['vote_count'] as num?)?.toDouble() ?? 0;
            final voteLog = math.log(votes + 1);
            return math.max(current, voteLog);
          },
        );

        final releaseYears = indexedResults
            .map((entry) => extractYear(entry.value))
            .whereType<int>()
            .toList();

        final int? minYear = releaseYears.isEmpty
            ? null
            : releaseYears.reduce(
                (value, element) => math.min(value, element),
              );
        final int? maxYear = releaseYears.isEmpty
            ? null
            : releaseYears.reduce(
                (value, element) => math.max(value, element),
              );

        double computeYearScore(int? year) {
          if (year == null ||
              minYear == null ||
              maxYear == null ||
              minYear == maxYear) {
            return 0.5;
          }
          final normalized = (year - minYear) / (maxYear - minYear);
          return normalized.clamp(0, 1).toDouble();
        }

        double computeMatchScore(Map<String, dynamic> item) {
          final title = (item['title'] ??
                  item['name'] ??
                  item['original_title'] ??
                  item['original_name'] ??
                  '')
              .toString();
          final normalizedTitle = normalizeText(title);
          if (normalizedTitle.isEmpty || normalizedQuery.isEmpty) {
            return 0.45;
          }

          final strippedTitle = stripLeadingArticles(normalizedTitle);

          if (normalizedTitle == normalizedQuery ||
              strippedTitle == strippedQuery) {
            return 1.0;
          }

          if (strippedTitle.startsWith('$strippedQuery ')) {
            return 0.96;
          }

          if (normalizedTitle.startsWith('$normalizedQuery ')) {
            return 0.94;
          }

          final titleTokens = tokenize(title);
          if (queryTokens.isNotEmpty && titleTokens.isNotEmpty) {
            final intersection = queryTokens.intersection(titleTokens);
            if (intersection.isNotEmpty) {
              if (intersection.length == queryTokens.length) {
                return titleTokens.length == queryTokens.length ? 0.92 : 0.88;
              }
              final coverage = intersection.length / queryTokens.length;
              if (coverage >= 0.6) {
                return 0.8;
              }
              return 0.68;
            }
          }

          if (normalizedTitle.contains(normalizedQuery)) {
            return 0.65;
          }

          return 0.45;
        }

        double computeScore(Map<String, dynamic> item) {
          final popularity = (item['popularity'] as num?)?.toDouble() ?? 0;
          final votes = (item['vote_count'] as num?)?.toDouble() ?? 0;
          final popScore = maxPopularity > 0
              ? (popularity / maxPopularity).clamp(0, 1)
              : 0.0;
          final voteScore = maxVoteLog > 0
              ? (math.log(votes + 1) / maxVoteLog).clamp(0, 1)
              : 0.0;
          final matchScore = computeMatchScore(item);
          final yearScore = computeYearScore(extractYear(item));
          final mediaScore = mediaPriority(item);

          return (mediaScore * 40) +
              (matchScore * 50) +
              (voteScore * 25) +
              (popScore * 15) +
              (yearScore * 5);
        }

        indexedResults.sort((a, b) {
          final scoreA = computeScore(a.value);
          final scoreB = computeScore(b.value);
          final scoreComparison = scoreB.compareTo(scoreA);
          if (scoreComparison != 0) return scoreComparison;

          final mediaComparison =
              mediaPriority(b.value).compareTo(mediaPriority(a.value));
          if (mediaComparison != 0) return mediaComparison;

          final matchComparison =
              computeMatchScore(b.value).compareTo(computeMatchScore(a.value));
          if (matchComparison != 0) return matchComparison;

          final popularityA = (a.value['popularity'] as num?)?.toDouble() ?? 0;
          final popularityB = (b.value['popularity'] as num?)?.toDouble() ?? 0;
          final popularityComparison = popularityB.compareTo(popularityA);
          if (popularityComparison != 0) return popularityComparison;

          final votesA = (a.value['vote_count'] as num?)?.toDouble() ?? 0;
          final votesB = (b.value['vote_count'] as num?)?.toDouble() ?? 0;
          final votesComparison = votesB.compareTo(votesA);
          if (votesComparison != 0) return votesComparison;

          final yearA = extractYear(a.value) ?? -1;
          final yearB = extractYear(b.value) ?? -1;
          final yearComparison = yearB.compareTo(yearA);
          if (yearComparison != 0) return yearComparison;

          return a.key.compareTo(b.key);
        });

        results = indexedResults.map((entry) => entry.value).toList();
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      print('🔍 Found ${results.length} results');
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      showZagSnackBar(
        title: 'Search Error',
        message: 'Failed to search. Please try again.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  void _showMegaRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star_border_rounded, color: ZagColours.purple),
            const SizedBox(width: 12),
            const Text('Zagreus Mega Required'),
          ],
        ),
        content: const Text(
          'Mosaic is a Zagreus Mega exclusive feature.\n\n'
          'Upgrade to Zagreus Mega to unlock AI-powered recommendations!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SettingsRoutes.SUBSCRIPTIONS.go();
            },
            child: Text(
              'View Subscriptions',
              style: TextStyle(color: ZagColours.purple),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _askZAssistant(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isAskingZAssistant = true;
    });

    try {
      print('🤖 Asking Z Assistant: $query');
      final service = ZAssistantService();
      final stageId = await service.sendExploreQuery(query: query);

      setState(() {
        _isAskingZAssistant = false;
      });

      print('🤖 Z Assistant returned stage ID: $stageId');

      // Store stage ID for navigation history
      setState(() {
        _lastZAssistantStageId = stageId;
      });

      // Navigate to fullscreen results
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZAssistantResultsRoute(
            stageId: stageId,
            onMovieTap: (tmdbId, title) =>
                _openMovieInRadarr(tmdbId: tmdbId, title: title),
            onShowTap: (tmdbId, title, tvdbId) => _openSeriesInSonarr(
                tmdbId: tmdbId, tvdbId: tvdbId, title: title),
          ),
        ),
      );

      // Trigger library sync after navigation (fire and forget)
      Future.delayed(const Duration(milliseconds: 2500), () {
        final syncService = LibrarySyncService();
        if (syncService.needsSync) {
          ZagLogger().debug(
              'Mosaic completed - triggering background library sync...');
          syncService.syncIfNeeded();
        }

        // Also trigger watch history sync if needed
        final watchHistoryService = WatchHistorySyncService();
        if (watchHistoryService.needsSync) {
          ZagLogger().debug('Triggering background watch history sync...');
          watchHistoryService.syncIfNeeded();
        }
      });
    } catch (e) {
      print('❌ Z Assistant error: $e');
      setState(() {
        _isAskingZAssistant = false;
      });
      showZagSnackBar(
        title: 'Z Assistant Error',
        message: 'Failed to get results from Z Assistant. Please try again.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  void _navigateToLastZAssistantResults() {
    if (_lastZAssistantStageId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZAssistantResultsRoute(
          stageId: _lastZAssistantStageId!,
          onMovieTap: (tmdbId, title) =>
              _openMovieInRadarr(tmdbId: tmdbId, title: title),
          onShowTap: (tmdbId, title, tvdbId) =>
              _openSeriesInSonarr(tmdbId: tmdbId, tvdbId: tvdbId, title: title),
        ),
      ),
    );
  }

  Future<void> _forceLibrarySync() async {
    setState(() => _isSyncing = true);
    _refreshQuickSetupModal();

    try {
      final result = await LibrarySyncService().syncLibrary(force: true);

      if (mounted) {
        if (result.success) {
          showZagSnackBar(
            title: 'Library Synced',
            message: 'Your library has been synced to Z Assistant',
            type: ZagSnackbarType.SUCCESS,
          );

          // Also trigger watch history sync if enabled
          final watchHistoryResult =
              await WatchHistorySyncService().syncWatchHistory(force: true);
          if (watchHistoryResult.success) {
            showZagSnackBar(
              title: 'Watch History Synced',
              message: 'Your Tautulli watch history has been synced',
              type: ZagSnackbarType.SUCCESS,
            );
          } else if (watchHistoryResult.error !=
                  WatchHistorySyncError.cacheDisabled &&
              watchHistoryResult.error !=
                  WatchHistorySyncError.tautulliNotConfigured) {
            // Only show error if it's not just disabled/not configured
            showZagSnackBar(
              title: 'Watch History Sync Failed',
              message: watchHistoryResult.errorMessage ??
                  'Could not sync watch history',
              type: ZagSnackbarType.ERROR,
            );
          }
        } else {
          // Show specific error message based on error type
          String title;
          String message;
          ZagSnackbarType type;

          switch (result.error) {
            case LibrarySyncError.noMega:
              title = 'Sync Not Available';
              message =
                  'Library sync is available for Pro, Mega, and Ultra subscribers';
              type = ZagSnackbarType.INFO;
              break;
            case LibrarySyncError.cacheDisabled:
              title = 'Sync Disabled';
              message = 'Library cache is disabled in settings';
              type = ZagSnackbarType.INFO;
              break;
            case LibrarySyncError.alreadySyncing:
              title = 'Sync In Progress';
              message = 'A sync is already running';
              type = ZagSnackbarType.INFO;
              break;
            case LibrarySyncError.uploadFailed:
              title = 'Sync Failed';
              message = result.errorMessage ?? 'Could not upload to server';
              type = ZagSnackbarType.ERROR;
              break;
            case LibrarySyncError.unknown:
            default:
              title = 'Sync Failed';
              message = 'An unexpected error occurred';
              type = ZagSnackbarType.ERROR;
              break;
          }

          showZagSnackBar(
            title: title,
            message: message,
            type: type,
          );
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync library', e, stack);
      if (mounted) {
        showZagSnackBar(
          title: 'Sync Failed',
          message: 'Could not sync library. Please try again.',
          type: ZagSnackbarType.ERROR,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        _refreshQuickSetupModal();
      }
    }
  }

  Future<void> _loadAvailableUsers() async {
    if (!ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED.read()) {
      print('⏭️  Skipping user load - watch history cache disabled');
      return;
    }

    if (!mounted) return;
    setState(() => _loadingUsers = true);
    _refreshQuickSetupModal();

    try {
      final deviceId = DeviceIdService().deviceId;
      print(
          '📥 Loading available users for device: ${deviceId.substring(0, 8)}...');

      final service = ZAssistantService();
      final response = await service.getAvailableUsers(deviceId).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️  Request timed out');
          return ZAssistantApiResponse(
            success: false,
            error: 'Request timed out',
          );
        },
      );

      print('📥 Response success: ${response.success}');
      print('📥 Response data: ${response.data}');
      print('📥 Response error: ${response.error}');

      if (response.success && response.data != null) {
        final users = _parseUserOptions(response.data!['users']);
        print(
            '✅ Found ${users.length} available users: ${users.map((u) => u.label).toList()}');

        if (mounted) {
          setState(() {
            _availableUsers = users;
            final serverSelected = response.data!['selected_user_alias'];
            if (serverSelected != null) {
              _selectedUser = serverSelected;
              ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS
                  .update(serverSelected);
            } else {
              _selectedUser =
                  ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS.read();
            }
          });
          _refreshQuickSetupModal();
        }
      } else {
        print('❌ Failed to load users: ${response.error}');
        if (mounted) {
          showZagErrorSnackBar(
            title: 'Failed to Load Users',
            message: response.error ?? 'Unknown error',
          );
        }
      }
    } catch (e, stack) {
      print('❌ Error loading available users: $e');
      print('Stack trace: $stack');
      if (mounted) {
        showZagErrorSnackBar(
          title: 'Error',
          message: 'Failed to load Tautulli users: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingUsers = false);
        _refreshQuickSetupModal();
      }
    }
  }

  List<_UserOption> _parseUserOptions(dynamic rawUsers) {
    if (rawUsers is! List) {
      return [];
    }

    final Map<String, _UserOption> deduped = {};
    for (final entry in rawUsers) {
      if (entry is String) {
        deduped.putIfAbsent(
          entry,
          () => _UserOption(alias: entry, label: entry),
        );
        continue;
      }

      if (entry is Map) {
        final aliasValue = entry['alias'] ??
            entry['user_id_alias'] ??
            entry['value'] ??
            entry['id'];
        final alias = aliasValue?.toString();
        if (alias == null || alias.isEmpty) {
          continue;
        }

        final labelValue = entry['label'] ??
            entry['name'] ??
            entry['display_name'] ??
            entry['display'] ??
            alias;
        final label = labelValue?.toString() ?? alias;

        deduped.putIfAbsent(
          alias,
          () => _UserOption(alias: alias, label: label),
        );
      }
    }

    return deduped.values.toList();
  }

  _UserOption? _findUserOption(String? alias) {
    if (alias == null) {
      return null;
    }

    for (final option in _availableUsers) {
      if (option.alias == alias) {
        return option;
      }
    }
    return null;
  }

  String _labelForAlias(String? alias) {
    if (alias == null || alias.isEmpty) {
      return 'Unknown User';
    }
    return _findUserOption(alias)?.label ?? alias;
  }

  Future<void> _selectUser(String userAlias) async {
    try {
      final deviceId = DeviceIdService().deviceId;
      final service = ZAssistantService();
      final response = await service.selectUser(deviceId, userAlias);

      if (response.success) {
        setState(() => _selectedUser = userAlias);
        _refreshQuickSetupModal();
        ZagreusDatabase.Z_ASSISTANT_SELECTED_USER_ALIAS.update(userAlias);
        showZagSuccessSnackBar(
          title: 'User Selected',
          message:
              'Z Agent will now focus on ${_labelForAlias(userAlias)}\'s viewing history',
        );
      } else {
        showZagErrorSnackBar(
          title: 'Error',
          message: response.error ?? 'Failed to select user',
        );
      }
    } catch (e) {
      showZagErrorSnackBar(
        title: 'Error',
        message: 'Failed to select user: $e',
      );
    }
  }

  void _loadSavedSettings() {
    _radarrQualityProfileId =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _radarrQualityProfileName =
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _radarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing =
        ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read();

    _sonarrQualityProfileId =
        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
    _sonarrQualityProfileName =
        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.read();
    _sonarrRootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
    _sonarrMonitorType = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
    _sonarrSeriesType = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();
    _sonarrSearchForMissing =
        ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read();
    _sonarrSearchForCutoffUnmet =
        ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read();

    // Load poster height preference
    final savedHeight = ZagreusDatabase.DISCOVER_POSTER_HEIGHT.read();
    if (savedHeight != null && savedHeight >= 150 && savedHeight <= 250) {
      _posterHeight = savedHeight;
    }

    final savedHeroHeight = ZagreusDatabase.DISCOVER_HERO_HEIGHT.read();
    if (savedHeroHeight != null &&
        savedHeroHeight >= 320 &&
        savedHeroHeight <= 420) {
      _heroHeight = savedHeroHeight;
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

  void _showZAgentQuickSetup() {
    // Load available users when opening the setup
    _loadAvailableUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            _quickSetupModalSetState = modalSetState;
            final theme = Theme.of(context);
            final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            );

            return FractionallySizedBox(
              heightFactor: 0.65,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Z Agent setup',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Turn on these caches so the agent has library and watch history context. We send media path names and Tautulli usernames, which could be sensitive, but your credentials are never used — all server commands are sent back to your device and processed locally.',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 16),
                      ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED
                          .listenableBuilder(
                        builder: (context, _) {
                          final enabled = ZagreusDatabase
                              .Z_ASSISTANT_LIBRARY_CACHE_ENABLED
                              .read();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ZagBlock(
                              title: 'Library Cache',
                              body: [
                                TextSpan(
                                  text: enabled
                                      ? 'Library is synced to Z Agent'
                                      : 'Let Z Agent analyze your library',
                                ),
                              ],
                              trailing: ZagSwitch(
                                value: enabled,
                                onChanged: (value) {
                                  ZagreusDatabase
                                      .Z_ASSISTANT_LIBRARY_CACHE_ENABLED
                                      .update(value);
                                  if (value) {
                                    showZagInfoSnackBar(
                                      title: 'Library Cache Enabled',
                                      message:
                                          'Z Agent will now sync your library periodically',
                                    );
                                  } else {
                                    showZagInfoSnackBar(
                                      title: 'Library Cache Disabled',
                                      message:
                                          'Z Agent will no longer sync your library',
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      ZagreusDatabase.Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED
                          .listenableBuilder(
                        builder: (context, _) {
                          final enabled = ZagreusDatabase
                              .Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED
                              .read();
                          return ZagBlock(
                            title: 'Watch History Cache',
                            body: [
                              TextSpan(
                                text: enabled
                                    ? 'Tautulli watch history synced to Z Agent'
                                    : 'Sync your Tautulli watch history',
                              ),
                            ],
                            trailing: ZagSwitch(
                              value: enabled,
                              onChanged: (value) {
                                ZagreusDatabase
                                    .Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED
                                    .update(value);
                                if (value) {
                                  showZagInfoSnackBar(
                                    title: 'Watch History Cache Enabled',
                                    message:
                                        'Z Agent will now sync your Tautulli watch history',
                                  );
                                  _loadAvailableUsers();
                                } else {
                                  showZagInfoSnackBar(
                                    title: 'Watch History Cache Disabled',
                                    message:
                                        'Z Agent will no longer sync watch history',
                                  );
                                  setState(() {
                                    _availableUsers = [];
                                    _selectedUser = null;
                                  });
                                  _refreshQuickSetupModal();
                                }
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED
                          .listenableBuilder(
                        builder: (context, _) {
                          final enabled = ZagreusDatabase
                              .Z_ASSISTANT_LIBRARY_CACHE_ENABLED
                              .read();
                          if (!enabled) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Enable the library cache to trigger a manual sync.',
                                style: descriptionStyle,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          if (_isSyncing) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ZagColours.currentAccent,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Center(
                            child: TextButton(
                              onPressed: _forceLibrarySync,
                              style: TextButton.styleFrom(
                                foregroundColor: ZagColours.currentAccent,
                              ),
                              child: const Text('Sync library now'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Privacy notice
                      if (ZagreusDatabase
                              .Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED
                              .read() &&
                          (_availableUsers.isNotEmpty || _loadingUsers))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Usernames shown exactly as they appear in Tautulli. Only this device sees them.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      // User selection UI
                      if (ZagreusDatabase
                              .Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED
                              .read() &&
                          (_availableUsers.isNotEmpty || _loadingUsers))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ZagBlock(
                            title: 'Select Your Tautulli User',
                            body: [
                              TextSpan(
                                text: _selectedUser != null
                                    ? 'AI recommendations personalized for ${_labelForAlias(_selectedUser)}'
                                    : 'Choose which Tautulli user you are',
                              ),
                            ],
                            bottom: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                ..._availableUsers.map((userOption) {
                                  final isSelected =
                                      _selectedUser == userOption.alias;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ZagButton.text(
                                      text: userOption.label,
                                      icon: isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      onTap: () =>
                                          _selectUser(userOption.alias),
                                      backgroundColor: isSelected
                                          ? ZagColours.currentAccent
                                          : null,
                                    ),
                                  );
                                }).toList(),
                                if (_loadingUsers && _availableUsers.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                if (_availableUsers.isEmpty && !_loadingUsers)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Center(
                                      child: ZagButton.text(
                                        text: 'Load Users',
                                        icon: Icons.refresh,
                                        onTap: _loadAvailableUsers,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                              ],
                            ),
                            bottomHeight: (_availableUsers.length * 54.0) +
                                (_loadingUsers
                                    ? 40
                                    : _availableUsers.isEmpty
                                        ? 54
                                        : 0) +
                                12 +
                                _userListExtraPadding +
                                24,
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => _quickSetupModalSetState = null);
  }

  void _showZAssistantSettings() {
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
                    Tab(text: 'Shows'),
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
                        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID
                            .update(profile.id);
                        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME
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
            secondary: const Icon(Icons.search),
            title: const Text('Start search for missing'),
            value: _radarrSearchForMissing,
            onChanged: (value) {
              setState(() {
                _radarrSearchForMissing = value;
              });
              setModalState(() {});
              ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING
                  .update(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSonarrSettings() {
    // Helper to get monitor type enum from string
    final currentMonitorType =
        _sonarrMonitorType != null && _sonarrMonitorType!.isNotEmpty
            ? SonarrSeriesMonitorType.values.firstWhere(
                (type) => type.value == _sonarrMonitorType,
                orElse: () => SonarrSeriesMonitorType.ALL,
              )
            : SonarrSeriesMonitorType.ALL;

    // Helper to get series type enum from string
    final currentSeriesType =
        _sonarrSeriesType != null && _sonarrSeriesType!.isNotEmpty
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
                        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID
                            .update(profile.id);
                        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME
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
                        ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER
                            .update(folder.path);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tv),
            title: const Text('Monitor Type'),
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
                        ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE
                            .update(type.value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Series Type'),
            subtitle:
                Text(currentSeriesType.value?.toUpperCase() ?? 'STANDARD'),
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
                        ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE
                            .update(type.value);
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
              ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING
                  .update(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.upgrade),
            title: const Text('Search for cutoff unmet'),
            value: _sonarrSearchForCutoffUnmet,
            onChanged: (value) {
              setState(() {
                _sonarrSearchForCutoffUnmet = value;
              });
              setModalState(() {});
              ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET
                  .update(value);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _spamTenCalls() async {
    print('🔥 Spamming 10 API calls to test rate limiting...');
    final zAssistant = ZAssistantService();

    for (int i = 1; i <= 10; i++) {
      try {
        print('📡 Call #$i...');
        await zAssistant.sendExploreQuery(query: 'test call $i');
        print('✅ Call #$i successful');
      } catch (e) {
        print('❌ Call #$i failed: $e');
      }
    }

    print('🎉 Finished 10 calls!');
    showZagSnackBar(
      title: 'Rate Limit Test',
      message: 'Sent 10 requests. Check Xcode console for results.',
      type: ZagSnackbarType.INFO,
    );
  }

  Future<void> _loadTestZAssistantResults() async {
    try {
      print('🧪 Creating mock Z Assistant results');

      // Make a real API call to test authentication and rate limiting
      final zAssistant = ZAssistantService();
      try {
        print('📡 Testing Z Assistant API call...');
        await zAssistant.sendExploreQuery(query: 'test rate limiting');
        print('✅ Z Assistant API call successful');
      } catch (e) {
        print('⚠️ Z Assistant API call failed (expected if not Mega): $e');
      }

      // Mock Christopher Nolan movies with posters
      final mockItems = [
        {
          "tmdb_id": 496,
          "media_type": "movie",
          "title": "Following",
          "year": 1999,
          "poster_path": "/3bX6VVSMf0dvzk5pMT4ALG5A92d.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 77,
          "media_type": "movie",
          "title": "Memento",
          "year": 2000,
          "poster_path": "/fKTPH2WvH8nHTXeBYBVhawtRqtR.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 320,
          "media_type": "movie",
          "title": "Insomnia",
          "year": 2002,
          "poster_path": "/riVXh3EimGO0y5dgQxEWPRy5Itg.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 272,
          "media_type": "movie",
          "title": "Batman Begins",
          "year": 2005,
          "poster_path": "/sPX89Td70IDDjVr85jdSBb4rWGr.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 1124,
          "media_type": "movie",
          "title": "The Prestige",
          "year": 2006,
          "poster_path": "/2ZOzyhoW08neG27DVySMCcq2emd.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 155,
          "media_type": "movie",
          "title": "The Dark Knight",
          "year": 2008,
          "poster_path": "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 27205,
          "media_type": "movie",
          "title": "Inception",
          "year": 2010,
          "poster_path": "/ljsZTbVsrQSqZgWeep2B1QiDKuh.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 49026,
          "media_type": "movie",
          "title": "The Dark Knight Rises",
          "year": 2012,
          "poster_path": "/hr0L2aueqlP2BYUblTTjmtn0hw4.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 157336,
          "media_type": "movie",
          "title": "Interstellar",
          "year": 2014,
          "poster_path": "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 324857,
          "media_type": "movie",
          "title": "Dunkirk",
          "year": 2017,
          "poster_path": "/b4Oe15CGLL61Ped0RAS9JpqdmCt.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 577922,
          "media_type": "movie",
          "title": "Tenet",
          "year": 2020,
          "poster_path": "/aCIFMriQh8rvhxpN1IWGgvH0Tlg.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 872585,
          "media_type": "movie",
          "title": "Oppenheimer",
          "year": 2023,
          "poster_path": "/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
          "overview": "",
          "verified": true
        },
        {
          "tmdb_id": 1396,
          "media_type": "tv",
          "title": "Breaking Bad",
          "year": 2008,
          "poster_path": "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
          "overview":
              "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine in order to secure his family's future.",
          "verified": true,
          "tvdb_id": 81189
        },
        {
          "tmdb_id": 1399,
          "media_type": "tv",
          "title": "Game of Thrones",
          "year": 2011,
          "poster_path": "/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg",
          "overview":
              "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.",
          "verified": true,
          "tvdb_id": 121361
        },
      ];

      // Create staged operation locally
      final service = StagedOperationsService();
      final stageId = await service.createStagedOperation('explore', mockItems);

      print('🎯 Test stage created: $stageId');

      // Store stage ID for navigation history
      setState(() {
        _lastZAssistantStageId = stageId;
      });

      // Navigate to results
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZAssistantResultsRoute(
            stageId: stageId,
            onMovieTap: (tmdbId, title) =>
                _openMovieInRadarr(tmdbId: tmdbId, title: title),
            onShowTap: (tmdbId, title, tvdbId) => _openSeriesInSonarr(
              tmdbId: tmdbId,
              tvdbId: tvdbId,
              title: title,
            ),
          ),
        ),
      );
    } catch (e) {
      print('❌ Test Z Assistant error: $e');
      showZagSnackBar(
        title: 'Test Error',
        message: 'Failed to create test results: $e',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final mediaType = item['media_type'] as String?;
        final title = item['title'] ?? item['name'] ?? 'Unknown';
        final overview = item['overview'] ?? '';
        final posterPath = item['poster_path'] as String?;
        final profilePath = item['profile_path'] as String?;
        final releaseDate =
            item['release_date'] ?? item['first_air_date'] ?? '';
        final voteAverage = (item['vote_average'] ?? 0).toDouble();

        // Get appropriate image path
        String? imagePath;
        if (mediaType == 'person') {
          imagePath = profilePath;
        } else {
          imagePath = posterPath;
        }

        final imageUrl = imagePath != null
            ? 'https://image.tmdb.org/t/p/w185$imagePath'
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _handleSearchResultTap(item);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster/Profile image
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _searchResultPlaceholder(mediaType);
                              },
                            )
                          : _searchResultPlaceholder(mediaType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Media type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getMediaTypeColor(mediaType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getMediaTypeLabel(mediaType),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (releaseDate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            releaseDate.split('-').first,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                        if (mediaType != 'person' && voteAverage > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.yellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                voteAverage.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (overview.isNotEmpty && mediaType != 'person') ...[
                          const SizedBox(height: 6),
                          Text(
                            overview,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchResultPlaceholder(String? mediaType) {
    IconData icon;
    if (mediaType == 'person') {
      icon = Icons.person_rounded;
    } else if (mediaType == 'tv') {
      icon = Icons.tv_rounded;
    } else {
      icon = Icons.movie_rounded;
    }

    return Center(
      child: Icon(
        icon,
        size: 40,
        color: Colors.grey.shade600,
      ),
    );
  }

  Color _getMediaTypeColor(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return const Color(0xFF64B5F6); // Pastel blue
      case 'tv':
        return Colors.green;
      case 'person':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMediaTypeLabel(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return 'MOVIE';
      case 'tv':
        return 'TV SHOW';
      case 'person':
        return 'PERSON';
      default:
        return 'UNKNOWN';
    }
  }

  Future<void> _handleSearchResultTap(Map<String, dynamic> item) async {
    final mediaType = item['media_type'] as String?;
    final tmdbId = item['id'] as int;
    final title = item['title'] ?? item['name'] ?? 'Unknown';

    if (mediaType == 'movie') {
      // Try to find in Radarr first
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final movies = await radarrState.movies!;
        final movie = movies.firstWhere(
          (m) => m.tmdbId == tmdbId,
          orElse: () => RadarrMovie(),
        );

        if (movie.id != null) {
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
          return;
        }
      }

      await _openMovieInRadarr(tmdbId: tmdbId, title: title);
    } else if (mediaType == 'tv') {
      // For search results, we only have TMDB ID
      await _openSeriesInSonarr(
        tmdbId: tmdbId,
        title: title,
      );
    } else if (mediaType == 'person') {
      // Navigate to person details page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PersonDetailsRoute(
            personId: tmdbId,
            personName: title,
          ),
        ),
      );
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_rounded,
            size: 100,
            color: const Color(0xFF6688FF),
          ),
          const SizedBox(height: 20),
          Text(
            ZagModule.DISCOVER.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6688FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No recently downloaded movies',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCarousel({
    required PageController controller,
    required String storageKey,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.hasClients) {
        final currentPage =
            controller.page?.round() ?? controller.initialPage;
        if (currentPage != _currentHeroIndex) {
          controller.jumpToPage(_currentHeroIndex);
        }
      }
    });

    return SizedBox(
      height: _heroHeight,
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanCancel: () => _restartAutoScroll(),
            onPanEnd: (_) => _restartAutoScroll(),
            child: PageView.builder(
              key: PageStorageKey<String>(storageKey),
              controller: controller,
              onPageChanged: (index) {
                setState(() {
                  _currentHeroIndex = index;
                });
                _precacheHeroImage(index + 1);
                _precacheHeroImage(index - 1);
              },
              itemCount: _trendingItems.length,
              itemBuilder: (context, index) {
                final item = _trendingItems[index];
                return GestureDetector(
                  onTap: () => _handleHeroTap(item),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop image
                      Image.network(
                        item['backdrop'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Icon(
                                Icons.movie_rounded,
                                size: 60,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      // Content
                      Positioned(
                        bottom: 40,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // In library badge
                            if (item['inLibrary'] as bool)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'In library',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: _heroTitleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Rating and watching
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (item['rating'] as num) > 0
                                      ? (item['rating'] as num)
                                          .toStringAsFixed(1)
                                      : 'N/A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '• ${item['watchingNow']} watching now',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _trendingItems.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentHeroIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentHeroIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleHeroTap(Map<String, dynamic> item) async {
    final mediaType = item['mediaType'] as String;
    final tmdbId = item['tmdbId'] as int;

    if (mediaType == 'movie') {
      // Check if movie is in Radarr library
      final radarrState = context.read<RadarrState>();
      if (radarrState.enabled && radarrState.movies != null) {
        final movies = await radarrState.movies!;
        final movie = movies.firstWhere(
          (m) => m.tmdbId == tmdbId,
          orElse: () => RadarrMovie(),
        );

        if (movie.id != null) {
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
          return;
        }
      }

      await _openMovieInRadarr(
        tmdbId: tmdbId,
        title: item['title'] as String?,
      );
    } else if (mediaType == 'tv') {
      // Check if show is in Sonarr library
      final sonarrState = context.read<SonarrState>();
      if (sonarrState.enabled && sonarrState.series != null) {
        final series = await sonarrState.series!;
        final title = item['title'] as String?;

        // Try to find by title match
        if (title != null) {
          for (final show in series.values) {
            if (show.title?.toLowerCase() == title.toLowerCase()) {
              if (show.id != null) {
                SonarrRoutes.SERIES.go(
                  params: {
                    'series': show.id.toString(),
                  },
                );
                return;
              }
            }
          }
        }
      }

      await _openSeriesInSonarr(
        tmdbId: tmdbId,
        title: item['title'] as String?,
      );
    }
  }

  Widget _recommendedMoviesSection() {
    final previewMovies =
        _recommendedMovies.take(_discoverPreviewLimit).toList();
    final previewShows =
        _trendingNewTVShows.take(_discoverPreviewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: ZagIcons.RADARR,
          leadingIconColor: const Color(0xFFFEC333),
          moduleLabel: 'Radarr',
          moduleLabelColor: const Color(0xFFFEC333),
          title: 'Recommended',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscoverRecommendedRoute(
                  initialData: _recommendedMovies,
                ),
              ),
            );
          },
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdRecommended,
            loader: _loadRecommendedMovies,
            sectionLabel: 'Recommended',
          ),
        ),
        // Movie list or placeholder
        previewMovies.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _recommendedMoviesListKey,
                  controller: _sectionScrollController(_scrollIdRecommended),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: previewMovies.length,
                  itemBuilder: (context, index) {
                    final movie = previewMovies[index];
                    return _movieCard(movie);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Tap to view recommended movies',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _missingMoviesSection() {
    final previewMovies = _missingMovies.take(_discoverPreviewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: ZagIcons.RADARR,
          leadingIconColor: const Color(0xFFFEC333),
          moduleLabel: 'Radarr',
          moduleLabelColor: const Color(0xFFFEC333),
          title: 'Missing',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscoverMissingRoute(
                  initialData: _missingMovies,
                ),
              ),
            );
          },
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdMissing,
            loader: _loadMissingMovies,
            sectionLabel: 'Missing',
          ),
        ),
        // Movie list
        SizedBox(
          height: _posterListHeight,
          child: ListView.builder(
            key: _missingMoviesListKey,
            controller: _sectionScrollController(_scrollIdMissing),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: previewMovies.length,
            itemBuilder: (context, index) {
              final movie = previewMovies[index];
              return _missingMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _downloadingSoonSection() {
    final previewMovies = _downloadingSoon.take(_discoverPreviewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.schedule_rounded,
          leadingIconColor: Colors.orange,
          moduleLabel: 'Radarr',
          moduleLabelColor: const Color(0xFFFEC333),
          title: 'Downloading Soon',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscoverDownloadingSoonRoute(
                  initialData: _downloadingSoon,
                ),
              ),
            );
          },
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdDownloadingSoon,
            loader: _loadDownloadingSoon,
            sectionLabel: 'Downloading Soon',
          ),
        ),
        // Movie list
        SizedBox(
          height: _posterListHeight,
          child: _downloadingSoon.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No movies downloading soon',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monitored movies releasing within 28 days will appear here',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  key: _downloadingSoonListKey,
                  controller: _sectionScrollController(_scrollIdDownloadingSoon),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: previewMovies.length,
                  itemBuilder: (context, index) {
                    final movie = previewMovies[index];
                    return _downloadingSoonCard(movie);
                  },
                ),
        ),
      ],
    );
  }

  Widget _popularMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.local_fire_department_rounded,
          leadingIconColor: const Color(0xFF6688FF),
          moduleLabel: 'TMDB',
          moduleLabelColor: const Color(0xFF6688FF),
          title: 'Popular Movies',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _popularMovies.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TMDBPopularMoviesRoute(
                        initialData: _popularMovies,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdPopularMovies,
            loader: _loadPopularMovies,
            sectionLabel: 'Popular Movies',
          ),
          showArrow: _popularMovies.isNotEmpty,
        ),
        // Movie list or loading placeholder
        _popularMovies.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _popularMoviesListKey,
                  controller:
                      _sectionScrollController(_scrollIdPopularMovies),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _popularMovies[index];
                    return _popularMovieCard(movie);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading popular movies...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _popularMovieCard(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Could navigate to a detail view or add to Radarr
          _handlePopularMovieTap(movie);
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie['poster'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.movie_rounded,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // In library badge
                  if (movie['inLibrary'] == true)
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (movie['rating'] as num).toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(
                                (movie['rating'] as num).toDouble()),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        movie['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePopularMovieTap(Map<String, dynamic> movie) async {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final int? serviceItemId = movie['serviceItemId'] as int?;
    final int? tmdbId = movie['tmdbId'] as int?;

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
        title: movie['title'] ?? 'Movie',
        message: 'Missing TMDB identifier for this title.',
        type: ZagSnackbarType.ERROR,
      );
      return;
    }

    await _openMovieInRadarr(
      tmdbId: tmdbId,
      title: movie['title'] as String?,
    );
  }

  Widget _popularTVShowsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.tv_rounded,
          leadingIconColor: const Color(0xFF6688FF),
          moduleLabel: 'TMDB',
          moduleLabelColor: const Color(0xFF6688FF),
          title: 'Popular TV Shows',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _popularTVShows.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TMDBPopularTVShowsRoute(
                        initialData: _popularTVShows,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdPopularTv,
            loader: _loadPopularTVShows,
            sectionLabel: 'Popular TV Shows',
          ),
          showArrow: _popularTVShows.isNotEmpty,
        ),
        // TV show list or loading placeholder
        _popularTVShows.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _popularTvShowsListKey,
                  controller: _sectionScrollController(_scrollIdPopularTv),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularTVShows.length,
                  itemBuilder: (context, index) {
                    final show = _popularTVShows[index];
                    return _popularTVShowCard(show);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading popular TV shows...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _popularTVShowCard(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final double rating = (show['rating'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Could navigate to a detail view or add to Sonarr
          _handlePopularTVShowTap(show);
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: show['poster'] != null && show['poster'] != ''
                          ? Image.network(
                              show['poster'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _tvShowPosterPlaceholder();
                              },
                            )
                          : _tvShowPosterPlaceholder(),
                    ),
                  ),
                  // Rating badge - top left
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(rating),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // In-library indicator
                  if (inLibrary)
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
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        show['title'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tvShowPosterPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Center(
        child: Icon(
          Icons.tv_rounded,
          size: 40,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Future<void> _handlePopularTVShowTap(Map<String, dynamic> show) async {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;
    final int? tvdbId = show['tvdbId'] as int?;
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
      tvdbId: tvdbId,
      title: title,
    );
  }

  Widget _trendingNewTVShowsSection() {
    final previewShows =
        _trendingNewTVShows.take(_discoverPreviewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.trending_up_rounded,
          leadingIconColor: const Color(0xFF6688FF),
          moduleLabel: 'TMDB',
          moduleLabelColor: const Color(0xFF6688FF),
          title: 'Trending Shows',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _trendingNewTVShows.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TMDBTrendingNewTVShowsRoute(
                        initialData: _trendingNewTVShows,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdTrendingTv,
            loader: _loadTrendingNewTVShows,
            sectionLabel: 'Trending Shows',
          ),
          showArrow: _trendingNewTVShows.isNotEmpty,
        ),
        // TV show list or loading placeholder
        previewShows.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _trendingTvShowsListKey,
                  controller: _sectionScrollController(_scrollIdTrendingTv),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: previewShows.length,
                  itemBuilder: (context, index) {
                    final show = previewShows[index];
                    return _trendingNewTVShowCard(show);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading trending new TV shows...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _trendingNewTVShowCard(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final double rating = (show['rating'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Could navigate to a detail view or add to Sonarr
          _handleTrendingNewTVShowTap(show);
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: show['poster'] != null && show['poster'] != ''
                          ? Image.network(
                              show['poster'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _tvShowPosterPlaceholder();
                              },
                            )
                          : _tvShowPosterPlaceholder(),
                    ),
                  ),
                  // Rating badge - top left
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(rating),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // In-library indicator - top right
                  if (inLibrary)
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
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        show['title'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTrendingNewTVShowTap(Map<String, dynamic> show) async {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;
    final int? tvdbId = show['tvdbId'] as int?;
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
      tvdbId: tvdbId,
      title: title,
    );
  }

  Future<void> _openMovieInRadarr({
    required int tmdbId,
    String? title,
  }) async {
    final radarrState = context.read<RadarrState>();
    if (!radarrState.enabled || radarrState.api == null) {
      showZagSnackBar(
        title: title ?? 'Radarr',
        message: 'Connect Radarr to manage movies from Dashboard.',
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

  Future<void> _showRadarrMovieActions(RadarrMovie movie) async {
    if (!mounted || movie.id == null || movie.id == 0) return;
    try {
      HapticFeedback.lightImpact();
      final result = await RadarrDialogs().movieSettings(context, movie);
      if (!mounted) return;
      if (result.item1 && result.item2 != null) {
        result.item2!.execute(context, movie);
      }
    } catch (error, stack) {
      ZagLogger()
          .error('Failed to open Radarr actions for ${movie.title}', error, stack);
      showZagSnackBar(
        title: movie.title ?? 'Radarr',
        message: 'Unable to open Radarr actions right now.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _showSonarrSeriesActions({
    required int seriesId,
    String? seriesTitle,
  }) async {
    final sonarrState = context.read<SonarrState>();
    if (!sonarrState.enabled || sonarrState.api == null) {
      showZagSnackBar(
        title: seriesTitle ?? 'Sonarr',
        message: 'Connect Sonarr to manage shows from Dashboard.',
        type: ZagSnackbarType.INFO,
      );
      return;
    }

    try {
      SonarrSeries? series;
      Map<int, SonarrSeries>? cached;
      if (sonarrState.series != null) {
        cached = await sonarrState.series!;
        series = cached[seriesId];
      }

      if (series == null) {
        series = await sonarrState.api!.series
            .get(seriesId: seriesId, includeSeasonImages: true);
        if (series != null && sonarrState.series != null) {
          cached ??= await sonarrState.series!;
          cached[series.id!] = series;
        }
      }

      if (series == null) {
        showZagSnackBar(
          title: seriesTitle ?? 'Sonarr',
          message: 'Unable to load this series from Sonarr.',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      HapticFeedback.lightImpact();
      final result = await SonarrDialogs().seriesSettings(context, series);
      if (!mounted) return;
      if (result.item1 && result.item2 != null) {
        result.item2!.execute(context, series);
      }
    } catch (error, stack) {
      ZagLogger().error(
        'Failed to open Sonarr actions for series $seriesId',
        error,
        stack,
      );
      if (!mounted) return;
      showZagSnackBar(
        title: seriesTitle ?? 'Sonarr',
        message: 'Unable to open Sonarr actions right now.',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _openSeriesInSonarr(
      {int? tmdbId, int? tvdbId, String? title}) async {
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

      final query = tvdbId != null
          ? 'tvdb:$tvdbId'
          : tmdbId != null
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
          message: tvdbId != null
              ? 'Could not find TVDB ID $tvdbId in Sonarr.'
              : tmdbId != null
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

  Widget _mostAnticipatedShowsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.auto_awesome_rounded,
          leadingIconColor: const Color(0xFFED2224),
          moduleLabel: 'Trakt',
          moduleLabelColor: const Color(0xFFED2224),
          title: 'Most Anticipated Shows',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _mostAnticipatedShows.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TraktMostAnticipatedShowsRoute(
                        initialData: _mostAnticipatedShows,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdMostAnticipatedShows,
            loader: _loadMostAnticipatedShows,
            sectionLabel: 'Most Anticipated Shows',
          ),
          showArrow: _mostAnticipatedShows.isNotEmpty,
        ),
        // TV show list or loading placeholder
        _mostAnticipatedShows.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _mostAnticipatedShowsListKey,
                  controller: _sectionScrollController(
                      _scrollIdMostAnticipatedShows),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _mostAnticipatedShows.length,
                  itemBuilder: (context, index) {
                    final show = _mostAnticipatedShows[index];
                    return _mostAnticipatedShowCard(show);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading most anticipated shows...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _mostAnticipatedShowCard(Map<String, dynamic> show) {
    final bool inLibrary = show['inLibrary'] ?? false;
    final double rating = (show['rating'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          _handleMostAnticipatedShowTap(show);
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster with special styling
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: show['poster'] != null && show['poster'] != ''
                          ? Image.network(
                              show['poster'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _tvShowPosterPlaceholder();
                              },
                            )
                          : _tvShowPosterPlaceholder(),
                    ),
                  ),
                  // Rating badge (below HOT badge to avoid overlap)
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(rating),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // In-library indicator
                  if (inLibrary)
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
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        show['title'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMostAnticipatedShowTap(Map<String, dynamic> show) async {
    final bool inLibrary = show['inLibrary'] ?? false;
    final int? serviceItemId = show['serviceItemId'] as int?;
    final int? tmdbId = show['tmdbId'] as int?;
    final int? tvdbId = show['tvdbId'] as int?;
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
      tvdbId: tvdbId,
      title: title,
    );
  }

  Widget _mostAnticipatedMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.auto_awesome_rounded,
          leadingIconColor: const Color(0xFFED2224),
          moduleLabel: 'Trakt',
          moduleLabelColor: const Color(0xFFED2224),
          title: 'Most Anticipated Movies',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _mostAnticipatedMovies.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TraktMostAnticipatedMoviesRoute(
                        initialData: _mostAnticipatedMovies,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdMostAnticipatedMovies,
            loader: _loadMostAnticipatedMovies,
            sectionLabel: 'Most Anticipated Movies',
          ),
          showArrow: _mostAnticipatedMovies.isNotEmpty,
        ),
        _mostAnticipatedMovies.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _mostAnticipatedMoviesListKey,
                  controller:
                      _sectionScrollController(_scrollIdMostAnticipatedMovies),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _mostAnticipatedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _mostAnticipatedMovies[index];
                    return _mostAnticipatedMovieCard(movie);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading most anticipated movies...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _mostAnticipatedMovieCard(Map<String, dynamic> movie) {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final double rating = (movie['rating'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          _handleMostAnticipatedMovieTap(movie);
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: movie['poster'] != null && movie['poster'] != ''
                          ? Image.network(
                              movie['poster'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _mostAnticipatedMoviePlaceholder();
                              },
                            )
                          : _mostAnticipatedMoviePlaceholder(),
                    ),
                  ),
                  if (rating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: _ratingColor(rating),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (inLibrary)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: ZagColours.red,
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
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        movie['title'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mostAnticipatedMoviePlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 40,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Future<void> _handleMostAnticipatedMovieTap(
      Map<String, dynamic> movie) async {
    final bool inLibrary = movie['inLibrary'] ?? false;
    final int? serviceItemId = movie['serviceItemId'] as int?;
    final int? tmdbId = movie['tmdbId'] as int?;
    final String? title = movie['title'] as String?;

    if (inLibrary && serviceItemId != null) {
      RadarrRoutes.MOVIE.go(
        params: {
          'movie': serviceItemId.toString(),
        },
      );
      return;
    }

    if (tmdbId != null) {
      await _openMovieInRadarr(
        tmdbId: tmdbId,
        title: title,
      );
      return;
    }

    showZagSnackBar(
      title: title ?? 'Radarr',
      message: 'Missing TMDB identifier for this title.',
      type: ZagSnackbarType.ERROR,
    );
  }

  Widget _popularPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.people_rounded,
          leadingIconColor: const Color(0xFF6688FF),
          moduleLabel: 'TMDB',
          moduleLabelColor: const Color(0xFF6688FF),
          title: 'Popular People',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _popularPeople.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TMDBPopularPeopleRoute(
                        initialData: _popularPeople,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdPopularPeople,
            loader: _loadPopularPeople,
            sectionLabel: 'Popular People',
          ),
          showArrow: _popularPeople.isNotEmpty,
        ),
        // People list or loading placeholder
        _popularPeople.isNotEmpty
            ? SizedBox(
                height: 150,
                child: ListView.builder(
                  key: _popularPeopleListKey,
                  controller:
                      _sectionScrollController(_scrollIdPopularPeople),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularPeople.length,
                  itemBuilder: (context, index) {
                    final person = _popularPeople[index];
                    return _popularPersonCard(person);
                  },
                ),
              )
            : Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading popular people...',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  Widget _deepCutsSection() {
    final deepCutsService = DeepCutsService();

    // Initialize future once if not already set
    _deepCutsFuture ??= deepCutsService.fetchRecommendations();

    return FutureBuilder<DeepCutsResult>(
      future: _deepCutsFuture,
      builder: (context, futureSnapshot) {
        // Check if refresh is available (nextGenerationAt has passed)
        final canRefresh = !futureSnapshot.hasData ||
            !futureSnapshot.data!.success ||
            futureSnapshot.data!.nextGenerationAt == null ||
            DateTime.now().isAfter(futureSnapshot.data!.nextGenerationAt!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title with sync button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: ZagColours.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Z',
                    style: TextStyle(
                      fontSize: _moduleSectionTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: ZagColours.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Deep Cuts',
                      style: TextStyle(
                        fontSize: _moduleSectionTitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                  // Refresh button (hidden if cooldown active)
                  if (canRefresh)
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: ZagColours.purple,
                        size: 20,
                      ),
                      onPressed: () async {
                        await deepCutsService.generateRecommendations(
                            force: true);
                        if (mounted) {
                          setState(() {
                            _deepCutsFuture =
                                deepCutsService.fetchRecommendations();
                          });
                        }
                      },
                    ),
                ],
              ),
            ),
            // Content
            Builder(
              builder: (context) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 280,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!futureSnapshot.hasData ||
                    !futureSnapshot.data!.success ||
                    futureSnapshot.data!.recommendations == null ||
                    futureSnapshot.data!.recommendations!.isEmpty) {
                  return _deepCutsEmptyState(futureSnapshot.data);
                }

                final recommendations = futureSnapshot.data!.recommendations!;

                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    key: _deepCutsListKey,
                    controller:
                        _sectionScrollController(_scrollIdDeepCuts),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return _deepCutMovieCard(recommendations[index]);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _deepCutsEmptyState(DeepCutsResult? result) {
    // Determine message based on error type
    String title = 'No deep cuts yet';
    String message = 'Tap refresh to generate AI-powered recommendations';
    IconData icon = Icons.movie_filter_rounded;

    if (result != null && !result.success && result.error != null) {
      switch (result.error!) {
        case DeepCutsError.notSynced:
          title = 'Library not synced';
          message = result.errorMessage ?? 'Please sync your library first';
          icon = Icons.sync_problem_rounded;
          break;
        case DeepCutsError.noMegaOrUltra:
          title = 'Mega subscription required';
          message = result.errorMessage ?? 'Deep Cuts requires Mega or Ultra';
          icon = Icons.lock_rounded;
          break;
        case DeepCutsError.alreadyGenerating:
          title = 'Generation in progress';
          message = result.errorMessage ??
              'Please wait while recommendations are being generated';
          icon = Icons.hourglass_empty_rounded;
          break;
        case DeepCutsError.fetchFailed:
        case DeepCutsError.unknown:
          title = 'Something went wrong';
          message = result.errorMessage ?? 'Please try again later';
          icon = Icons.error_outline_rounded;
          break;
      }
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  .withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deepCutMovieCard(DeepCutMovie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          // Use tmdbId from backend if available
          if (movie.tmdbId != null) {
            await _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title);
          } else {
            // Fallback: search for the movie if no tmdbId
            final tmdbApi = TMDBApi();
            final searchResults =
                await tmdbApi.searchMulti('${movie.title} ${movie.year}');

            // Filter for movies only
            final movieResults =
                searchResults.where((r) => r['media_type'] == 'movie').toList();

            if (movieResults.isNotEmpty) {
              final tmdbId = movieResults.first['id'] as int;
              await _openMovieInRadarr(tmdbId: tmdbId, title: movie.title);
            }
          }
        },
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  border: movie.posterUrl == null
                      ? Border.all(
                          color: ZagColours.purple.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                  image: movie.posterUrl != null
                      ? DecorationImage(
                          image: NetworkImage(movie.posterUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: movie.posterUrl == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_filter_rounded,
                              size: 48,
                              color: ZagColours.purple.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                movie.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${movie.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              // Reason
              Text(
                movie.reason,
                style: TextStyle(
                  fontSize: 12,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.7),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popularPersonCard(Map<String, dynamic> person) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PersonDetailsRoute(
                personId: person['id'],
                personName: person['name'],
              ),
            ),
          );
        },
        child: Column(
          children: [
            // Circular avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: person['profilePath'] != null
                    ? Image.network(
                        person['profilePath'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _personPlaceholder();
                        },
                      )
                    : _personPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Container(
              width: 90,
              child: Text(
                person['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Known for (department)
            if (person['knownForDepartment'] != null)
              Text(
                person['knownForDepartment'],
                style: TextStyle(
                  fontSize: 10,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _personPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _missingMovieCard(RadarrMovie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to movie detail
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: _posterHeight,
                      width: _posterWidth,
                      color: Colors.grey.shade800,
                      child: _buildPosterImage(context, movie),
                    ),
                  ),
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        movie.title ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _downloadingSoonCard(RadarrMovie movie) {
    // Format release date (matching Zebrra logic)
    String releaseText = '';
    DateTime? releaseDate = movie.digitalRelease ?? movie.physicalRelease;

    if (releaseDate != null) {
      // Calculate days using UTC dates (matching Zebrra)
      final now = DateTime.now();
      final nowUtc = now.toUtc();
      final releaseDateUtc = releaseDate.toUtc();

      // Compare start of days in UTC
      final startOfTodayUtc =
          DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
      final startOfReleaseUtc = DateTime.utc(
          releaseDateUtc.year, releaseDateUtc.month, releaseDateUtc.day);

      final daysUntil = startOfReleaseUtc.difference(startOfTodayUtc).inDays;

      if (daysUntil == 0) {
        releaseText = 'TODAY';
      } else if (daysUntil == 1) {
        releaseText = 'TOMORROW';
      } else {
        releaseText = 'IN $daysUntil DAYS';
      }
    } else {
      releaseText = 'TBA';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Navigate to movie detail
          RadarrRoutes.MOVIE.go(
            params: {
              'movie': movie.id.toString(),
            },
          );
        },
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster with release date indicator
              Stack(
                children: [
                  // Poster container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: _posterHeight,
                      width: _posterWidth,
                      color: Colors.grey.shade800,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPosterImage(context, movie),
                          // Orange gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.orange.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.5],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Release date badge
                  if (releaseText.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          releaseText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Title gradient overlay (on top of orange gradient)
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        movie.title ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentlyDownloadedSection() {
    final previewMovies =
        _recentlyDownloaded.take(_discoverPreviewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: ZagIcons.RADARR,
          leadingIconColor: const Color(0xFFFEC333),
          moduleLabel: 'Radarr',
          moduleLabelColor: const Color(0xFFFEC333),
          title: 'Recently Downloaded',
          titleStyle: TextStyle(
            fontSize: _moduleSectionTitleFontSize,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscoverRecentlyDownloadedRoute(
                  initialData: _recentlyDownloaded,
                ),
              ),
            );
          },
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdRecentlyDownloaded,
            loader: () => _loadRecentlyDownloaded(showGlobalLoader: false),
            sectionLabel: 'Recently Downloaded',
          ),
          trailingIcon: Icons.chevron_right_rounded,
          trailingColor: Colors.grey,
          trailingSize: 24,
          showArrow: true,
        ),
        // Movie list
        SizedBox(
          height: _posterListHeight,
          child: ListView.builder(
            key: _recentlyDownloadedListKey,
            controller: _sectionScrollController(_scrollIdRecentlyDownloaded),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: previewMovies.length,
            itemBuilder: (context, index) {
              final item = previewMovies[index];
              return _movieCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _movieCard(RadarrMovie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () async {
          // Check if movie is already in library
          if (movie.id != null && movie.id! > 0) {
            // Movie is in library, navigate to details
            RadarrRoutes.MOVIE.go(
              params: {
                'movie': movie.id.toString(),
              },
            );
          } else if (movie.tmdbId != null) {
            // Movie not in library, open add screen
            await _openMovieInRadarr(
              tmdbId: movie.tmdbId!,
              title: movie.title,
            );
          }
        },
        onLongPress:
            movie.id != null ? () => _showRadarrMovieActions(movie) : null,
        child: Container(
          width: _posterWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster with title overlay
              Stack(
                children: [
                  Container(
                    height: _posterHeight,
                    width: _posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade800,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPosterImage(context, movie),
                    ),
                  ),
                  // Gradient overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: _posterHeight,
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
                    ),
                  // Title overlay
                  if (ZagreusDatabase.DISCOVER_SHOW_TITLES.read())
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        movie.title ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                movie.title ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
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

  Widget _recentlyDownloadedShowsSection() {
    // Limit to 3 items for the home view
    final displayItems = _recentlyDownloadedShows.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with navigation
        _sectionTitleRow(
          context: context,
          leadingIcon: ZagIcons.SONARR,
          leadingIconColor: ZagColours.blue,
          moduleLabel: 'Sonarr',
          moduleLabelColor: ZagColours.blue,
          title: 'Recently Downloaded',
          titleStyle: TextStyle(
            fontSize: _moduleSectionTitleFontSize,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SonarrRecentlyDownloadedRoute(
                  initialData: _recentlyDownloadedShows,
                ),
              ),
            );
          },
          onLongPress: () => _loadRecentlyDownloadedShows(),
          trailingColor: Colors.grey.withOpacity(0.7),
          showArrow: true,
        ),
        // TV show list with thin cards (limited to 3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...displayItems.map((episode) => _tvShowCard(episode)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _airingNextSection() {
    // Limit to 3 items for the home view
    final displayItems = _airingNextShows.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with navigation
        _sectionTitleRow(
          context: context,
          leadingIcon: ZagIcons.SONARR,
          leadingIconColor: ZagColours.blue,
          moduleLabel: 'Sonarr',
          moduleLabelColor: ZagColours.blue,
          title: 'Airing Next',
          titleStyle: TextStyle(
            fontSize: _moduleSectionTitleFontSize,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SonarrAiringNextRoute(
                  initialData: _airingNextShows,
                ),
              ),
            );
          },
          onLongPress: () => _loadSonarrAiringNext(),
          trailingColor: Colors.grey.withOpacity(0.7),
          showArrow: true,
        ),
        // TV show list with thin cards (limited to 3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (displayItems.isEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: ZagColours.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ZagColours.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'No Shows Airing Soon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ...displayItems
                  .map((episode) => _airingNextCard(episode))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _airingNextCard(Map<String, dynamic> episode) {
    final secondaryTextColor = Theme.of(context)
            .textTheme
            .bodySmall
            ?.color
            ?.withOpacity(0.65) ??
        Colors.grey.shade700;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: _recentlyDownloadedEpisodeThumbHeight,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (episode['seriesId'] != null) {
                SonarrRoutes.SERIES.go(
                  params: {
                    'series': episode['seriesId'].toString(),
                  },
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: _recentlyDownloadedEpisodeThumbWidth,
                  height: _recentlyDownloadedEpisodeThumbHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: Colors.grey.shade800,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: episode['thumbnail'] != null
                        ? Image.network(
                            episode['thumbnail'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.tv_rounded,
                                  size: 30,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.tv_rounded,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode['seriesTitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')} • ${episode['episodeTitle']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatAiringTime(
                                    episode['airDateUtc'], episode['network']),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ZagColours.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (episode['hasFile'] == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Downloaded',
                            style: TextStyle(
                              fontSize: 11,
                              color: ZagColours.currentAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tvShowCard(Map<String, dynamic> episode) {
    final sizeGb = episode['sizeGb'] is num ? episode['sizeGb'] as num : null;
    final secondaryTextColor = Theme.of(context)
            .textTheme
            .bodySmall
            ?.color
            ?.withOpacity(0.65) ??
        Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: _recentlyDownloadedEpisodeThumbHeight,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final seriesId = episode['seriesId'];
              if (seriesId is int) {
                SonarrRoutes.SERIES.go(
                  params: {
                    'series': seriesId.toString(),
                  },
                );
              } else {
                showZagSnackBar(
                  title: episode['seriesTitle'] ?? 'Sonarr',
                  message: 'Unable to open this show in Sonarr right now.',
                  type: ZagSnackbarType.ERROR,
                );
              }
            },
            onLongPress: () {
              final seriesId = episode['seriesId'];
              if (seriesId is int) {
                _showSonarrSeriesActions(
                  seriesId: seriesId,
                  seriesTitle: episode['seriesTitle'] as String?,
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: _recentlyDownloadedEpisodeThumbWidth,
                  height: _recentlyDownloadedEpisodeThumbHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: Colors.grey.shade800,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      episode['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.tv_rounded,
                            size: 30,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode['seriesTitle'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          episode['episodeTitle'],
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (sizeGb != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${sizeGb.toStringAsFixed(2)} GB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ZagColours.currentAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverNavigationBar extends StatelessWidget {
  final PageController? pageController;
  final bool showLegacyModules;
  final bool showAgentTab;

  static final ScrollController modulesScrollController =
      ScrollController();
  static final ScrollController moviesScrollController = ScrollController();
  static final ScrollController showsScrollController = ScrollController();
  static final ScrollController calendarScrollController =
      ScrollController();
  static final ScrollController agentScrollController = ScrollController();

  const _DiscoverNavigationBar({
    Key? key,
    required this.pageController,
    required this.showLegacyModules,
    required this.showAgentTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      if (showLegacyModules) Icons.workspaces_rounded,
      Icons.movie_rounded,
      Icons.tv_rounded,
      Icons.calendar_today_rounded,
      Icons.dns_rounded,
    ];

    final titles = <String>[
      if (showLegacyModules) 'Modules',
      'Movies',
      'Shows',
      'Calendar',
      'Server',
    ];

    final controllers = <ScrollController>[
      if (showLegacyModules) modulesScrollController,
      moviesScrollController,
      showsScrollController,
      calendarScrollController,
      ScrollController(),
    ];

    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: controllers,
      icons: icons,
      titles: titles,
      onTabChange: (index) {
        // All tabs navigate normally within the PageView
      },
    );
  }
}

class _ServerPage extends StatefulWidget {
  const _ServerPage({Key? key}) : super(key: key);

  @override
  State<_ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<_ServerPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<RadarrDiskSpace> _diskSpaces = [];
  List<_ServerIssue> _serverIssues = [];
  List<OverseerrRequest> _overseerrRequests = [];
  Map<String, double> _downloadHistoryChartData = {};
  double _downloadHistoryTotalGB = 0;
  bool _overseerrEnabled = false;
  bool _overseerrLoading = false;
  String? _overseerrError;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadDiskSpaces(),
      _loadServerIssues(),
      _loadOverseerrRequests(),
      _loadDownloadHistory(),
    ]);
  }

  Future<void> _loadDiskSpaces() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allDiskSpaces = <RadarrDiskSpace>[];

      // Fetch from Radarr if enabled
      if (ZagProfile.current.radarrEnabled) {
        try {
          final radarrAPI = RadarrAPI(
            host: ZagProfile.current.radarrHost,
            apiKey: ZagProfile.current.radarrKey,
            headers: ZagProfile.current.radarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.radarrHeaders)
                : null,
          );
          final radarrSpaces = await radarrAPI.fileSystem.getDiskSpace();
          allDiskSpaces.addAll(radarrSpaces);
        } catch (e) {
          ZagLogger().warning('Failed to fetch disk spaces from Radarr: $e');
        }
      }

      // Fetch from Sonarr if enabled
      if (ZagProfile.current.sonarrEnabled) {
        try {
          final sonarrAPI = SonarrAPI(
            host: ZagProfile.current.sonarrHost,
            apiKey: ZagProfile.current.sonarrKey,
            headers: ZagProfile.current.sonarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.sonarrHeaders)
                : null,
          );
          final sonarrSpaces = await sonarrAPI.filesystem.getAllDiskSpaces();
          // Convert SonarrDiskSpace to RadarrDiskSpace format
          allDiskSpaces.addAll(sonarrSpaces.map((s) => RadarrDiskSpace(
            path: s.path,
            label: s.label,
            freeSpace: s.freeSpace,
            totalSpace: s.totalSpace,
          )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch disk spaces from Sonarr: $e');
        }
      }

      // Remove duplicates by path (case-insensitive)
      final seen = <String>{};
      final uniqueSpaces = <RadarrDiskSpace>[];
      for (final space in allDiskSpaces) {
        final pathLower = space.path?.toLowerCase() ?? '';
        if (pathLower.isNotEmpty && !seen.contains(pathLower)) {
          seen.add(pathLower);
          uniqueSpaces.add(space);
        }
      }

      // Sort by path
      uniqueSpaces.sort((a, b) =>
        (a.path ?? '').toLowerCase().compareTo((b.path ?? '').toLowerCase())
      );

      if (mounted) {
        setState(() {
          _diskSpaces = uniqueSpaces;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadServerIssues() async {
    if (!mounted) return;

    try {
      final allIssues = <_ServerIssue>[];

      // Fetch from Radarr if enabled
      if (ZagProfile.current.radarrEnabled) {
        try {
          final radarrAPI = RadarrAPI(
            host: ZagProfile.current.radarrHost,
            apiKey: ZagProfile.current.radarrKey,
            headers: ZagProfile.current.radarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.radarrHeaders)
                : null,
          );
          final radarrIssues = await radarrAPI.healthCheck.get();
          allIssues.addAll(radarrIssues.map((issue) => _ServerIssue(
            message: issue.message ?? 'Unknown issue',
            serviceType: 'Radarr',
            icon: ZagIcons.RADARR,
            color: const Color(0xFFFEC333),
          )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch health checks from Radarr: $e');
        }
      }

      // Fetch from Sonarr if enabled
      if (ZagProfile.current.sonarrEnabled) {
        try {
          final sonarrAPI = SonarrAPI(
            host: ZagProfile.current.sonarrHost,
            apiKey: ZagProfile.current.sonarrKey,
            headers: ZagProfile.current.sonarrHeaders.isNotEmpty
                ? Map<String, dynamic>.from(ZagProfile.current.sonarrHeaders)
                : null,
          );
          final sonarrIssues = await sonarrAPI.healthCheck.get();
          allIssues.addAll(sonarrIssues.map((issue) => _ServerIssue(
            message: issue.message ?? 'Unknown issue',
            serviceType: 'Sonarr',
            icon: ZagIcons.SONARR,
            color: const Color(0xFF3FC6F4),
          )));
        } catch (e) {
          ZagLogger().warning('Failed to fetch health checks from Sonarr: $e');
        }
      }

      // Fetch from Lidarr if enabled (when we add it)
      if (ZagProfile.current.lidarrEnabled) {
        // TODO: Add Lidarr health check support
      }

      if (mounted) {
        setState(() {
          _serverIssues = allIssues;
        });
      }
    } catch (e) {
      ZagLogger().warning('Failed to load server issues: $e');
    }
  }

  Future<void> _loadOverseerrRequests() async {
    if (!mounted) return;

    final overseerrState = context.read<OverseerrState>();
    final isConfigured = overseerrState.enabled &&
        overseerrState.host.isNotEmpty &&
        overseerrState.apiKey.isNotEmpty;

    if (!isConfigured) {
      if (!mounted) return;
      setState(() {
        _overseerrEnabled = false;
        _overseerrLoading = false;
        _overseerrError = null;
        _overseerrRequests = [];
      });
      return;
    }

    setState(() {
      _overseerrEnabled = true;
      _overseerrLoading = true;
      _overseerrError = null;
    });

    try {
      await overseerrState.fetchRequests();
      final requests = overseerrState.requests ?? [];
      final sorted = List<OverseerrRequest>.from(requests)
        ..sort(
          (a, b) {
            final aDate = DateTime.tryParse(a.createdAt) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = DateTime.tryParse(b.createdAt) ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          },
        );

      if (!mounted) return;
      setState(() {
        _overseerrRequests = sorted;
        _overseerrLoading = false;
        _overseerrError = overseerrState.requestsError;
      });
    } catch (e) {
      ZagLogger().warning('Failed to fetch Overseerr requests: $e');
      if (!mounted) return;
      setState(() {
        _overseerrError = e.toString();
        _overseerrLoading = false;
        _overseerrRequests = [];
      });
    }
  }

  bool get _shouldShowOverseerrSection =>
      _overseerrEnabled ||
      _overseerrLoading ||
      _overseerrError != null ||
      _overseerrRequests.isNotEmpty;

  Future<void> _loadDownloadHistory() async {
    if (!mounted) return;

    try {
      print('🔍 Loading download history - SABnzbd enabled: ${ZagProfile.current.sabnzbdEnabled}');
      if (ZagProfile.current.sabnzbdEnabled) {
        final sabnzbdApi = SABnzbdAPI.from(ZagProfile.current);
        final historyData = await DownloadHistoryFetcher.fetchSabnzbdDownloadStats(
          api: sabnzbdApi,
          weeksLookBack: 1, // Default to 1 week
        );
        
        print('🔍 Download history loaded: ${historyData.chartData.length} days, ${historyData.totalGB} GB');
        print('🔍 Chart data: ${historyData.chartData}');
        
        if (!mounted) return;
        setState(() {
          _downloadHistoryChartData = historyData.chartData;
          _downloadHistoryTotalGB = historyData.totalGB;
        });
        
        print('🔍 State updated with download history');
      } else {
        print('🔍 SABnzbd not enabled, skipping download history');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load download history: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load download history: $e');
      // Fail silently - this is optional data
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load server data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_diskSpaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dns_rounded,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No disk space data available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable Radarr or Sonarr to view disk spaces',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ZagColours.currentAccent,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Server Issues Card
          if (_serverIssues.isNotEmpty || ZagProfile.current.radarrEnabled || ZagProfile.current.sonarrEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'Server Issues',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _serverIssues.isEmpty ? Colors.green : Colors.orange,
                ),
              ),
            ),
            if (_serverIssues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ZagBlock(
                  title: 'No Server Issues',
                  body: const [
                    TextSpan(text: 'All systems are healthy! 🎉'),
                  ],
                  trailing: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              )
            else
              ..._serverIssues.map((issue) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ZagBlock(
                  title: issue.message,
                  titleMaxLines: 5,
                  leading: Icon(
                    issue.icon,
                    color: issue.color,
                    size: 28,
                  ),
                ),
              )),
            const SizedBox(height: 24),
          ],
          if (_shouldShowOverseerrSection) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'Overseerr Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _overseerrEnabled
                      ? ZagModule.OVERSEERR.color
                      : Colors.grey,
                ),
              ),
            ),
            if (_overseerrLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: ZagLoader(),
                ),
              )
            else if (!_overseerrEnabled)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ZagBlock(
                  title: 'Enable Overseerr',
                  body: const [
                    TextSpan(
                      text:
                          'Turn on Overseerr in Settings to see requests here.',
                    ),
                  ],
                  trailing: const Icon(Icons.settings_rounded),
                  onTap: SettingsRoutes.CONFIGURATION_OVERSEERR.go,
                ),
              )
            else if (_overseerrError != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ZagBlock(
                  title: 'Unable to load requests',
                  body: const [
                    TextSpan(
                      text: 'Tap to retry. We could not reach Overseerr.',
                    ),
                  ],
                  trailing: const Icon(Icons.refresh_rounded),
                  onTap: _loadOverseerrRequests,
                ),
              )
            else if (_overseerrRequests.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ZagBlock(
                  title: 'No pending requests',
                  body: const [
                    TextSpan(text: 'All caught up for now.'),
                  ],
                  trailing: const Icon(Icons.inbox_outlined),
                  onTap: () => ZagModule.OVERSEERR.launch(),
                ),
              )
            else
              ..._overseerrRequests
                  .take(_overseerrPreviewLimit)
                  .map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OverseerrRequestTile(
                        request: request,
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
          ],
          // Disk Space Card
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              'Disk Space',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ZagColours.currentAccent,
              ),
            ),
          ),
          // Disk space tiles
          ..._diskSpaces.map((diskSpace) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadarrDiskSpaceTile(diskSpace: diskSpace),
          )),
          // Download History Card
          if (ZagProfile.current.sabnzbdEnabled) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'Download History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ZagColours.currentAccent,
                ),
              ),
            ),
            DownloadHistoryCard(
              chartData: _downloadHistoryChartData,
              totalGB: _downloadHistoryTotalGB,
              periodLabel: 'week',
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple class to hold server issue data with service metadata
class _ServerIssue {
  final String message;
  final String serviceType;
  final IconData icon;
  final Color color;

  _ServerIssue({
    required this.message,
    required this.serviceType,
    required this.icon,
    required this.color,
  });
}
