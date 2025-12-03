import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:zagreus/modules/discover/routes/tmdb_recently_released_movies/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_popular_tv_shows/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_trending_new_tv_shows/route.dart';
import 'package:zagreus/modules/discover/routes/tmdb_popular_people/route.dart';
import 'package:zagreus/modules/discover/routes/trakt_most_anticipated_shows/route.dart';
import 'package:zagreus/modules/discover/routes/trakt_most_anticipated_movies/route.dart';
import 'package:zagreus/modules/discover/routes/z_assistant_results/route.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';
import 'package:zagreus/modules/discover/widgets/discover_sections_editor.dart';
import 'package:zagreus/modules/discover/widgets/server_sections_editor.dart';
import 'package:zagreus/modules/radarr/core/dialogs.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/ui_preferences.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/services/z_conversation_service.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:zagreus/services/library_sync_service.dart';
import 'package:zagreus/services/watch_history_sync_service.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/services/deep_cuts_service.dart';
import 'package:zagreus/services/up_next_service.dart';
import 'package:zagreus/services/magic_movies_service.dart';
import 'package:zagreus/services/magic_movies_cast_crew_service.dart';
import 'package:zagreus/services/magic_shows_service.dart';
import 'package:zagreus/services/magic_shows_cast_crew_service.dart';
import 'package:zagreus/modules/overseerr/core/extensions.dart';
import 'package:zagreus/modules/overseerr/core/state.dart';
import 'package:zagreus/modules/tautulli/core/state.dart';
import 'package:zagreus/modules/discover/widgets/tautulli_stream_card.dart';
import 'package:zagreus/api/tautulli/tautulli.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';
import 'package:zagreus/modules/sabnzbd/core/api/api.dart';
import 'package:zagreus/modules/unraid/core/download_history_fetcher.dart';
import 'package:zagreus/modules/unraid/routes/unraid/widgets/download_history_card.dart';
import 'package:zagreus/modules/lidarr/widgets/recently_downloaded_card.dart';
import 'package:zagreus/modules/lidarr/core/state.dart';
import 'package:zagreus/modules/lidarr/core/api/data/history.dart';
import 'package:zagreus/modules/lidarr/core/api/api.dart';
import 'package:zagreus/modules/readarr/widgets/recently_downloaded_card.dart';
import 'package:zagreus/modules/readarr/core/api/api.dart';
import 'package:zagreus/modules/readarr/core/api/data/history.dart';
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
  static const _scrollIdRecentlyReleasedMovies = 'recently_released_movies_section';
  static const _scrollIdPopularTv = 'popular_tv_shows_section';
  static const _scrollIdTrendingTv = 'trending_tv_shows_section';
  static const _scrollIdMostAnticipatedShows =
      'most_anticipated_shows_section';
  static const _scrollIdMostAnticipatedMovies =
      'most_anticipated_movies_section';
  static const _scrollIdPopularPeople = 'popular_people_section';
  static const _scrollIdDeepCuts = 'deep_cuts_recommendations';
  static const _scrollIdUpNext = 'up_next_recommendations';
  static const _scrollIdMagicMovies = 'magic_movies_recommendations';
  static const _scrollIdMagicMoviesCastCrew = 'magic_movies_cast_crew_recommendations';
  static const _scrollIdMagicShows = 'magic_shows_recommendations';
  static const _scrollIdMagicShowsCastCrew = 'magic_shows_cast_crew_recommendations';

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
  static const _recentlyReleasedMoviesListKey =
      PageStorageKey<String>('discover_recently_released_movies');
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
  static const _upNextListKey =
      PageStorageKey<String>('discover_up_next');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ZChatPageState> _agentChatKey = GlobalKey<ZChatPageState>();
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
  List<Map<String, dynamic>> _recentlyReleasedMovies = [];
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
  int _currentMovieHeroIndex = 0;
  int _currentTVHeroIndex = 0;
  String _trendingTimeWindow = 'day'; // 'day' or 'week'
  List<Map<String, dynamic>> _trendingMovies = [];
  List<Map<String, dynamic>> _trendingTVShows = [];
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
  bool _persistChatHistory = false;
  bool _supabaseChatSync = false;
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

  bool get _showHeroCarousel =>
      ZagreusDatabase.DISCOVER_SHOW_HERO_CAROUSEL.read() ?? true;

  // Deep Cuts future (cached to avoid refetching on rebuild)
  Future<DeepCutsResult>? _deepCutsFuture;
  bool _deepCutsSyncInitialized = false;

  // Up Next future (cached to avoid refetching on rebuild)
  Future<UpNextResult>? _upNextFuture;
  bool _upNextSyncInitialized = false;

  // Magic Movies future
  Future<MagicMoviesResult>? _magicMoviesFuture;
  bool _magicMoviesSyncInitialized = false;

  // Magic Movies Cast & Crew future
  Future<MagicMoviesCastCrewResult>? _magicMoviesCastCrewFuture;
  bool _magicMoviesCastCrewSyncInitialized = false;

  // Magic Shows future
  Future<MagicShowsResult>? _magicShowsFuture;
  bool _magicShowsSyncInitialized = false;

  // Magic Shows Cast & Crew future
  Future<MagicShowsCastCrewResult>? _magicShowsCastCrewFuture;
  bool _magicShowsCastCrewSyncInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadTrendingTimeWindowSetting();
    _ensureDiscoverDefaultTabIsValid();
    _pageController = ZagPageController(
      initialPage: _initialDiscoverTabIndex(),
    );
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
    _syncDeepCutsIfNeeded();
    _syncUpNextIfNeeded();
    _syncMagicMoviesIfNeeded();
    _syncMagicMoviesCastCrewIfNeeded();
    _syncMagicShowsIfNeeded();
    _syncMagicShowsCastCrewIfNeeded();
    // Listen for instance context changes (e.g. from add pages)
    ZagInstanceContext().addListener(_onInstanceContextChanged);
  }

  void _refreshQuickSetupModal() {
    _quickSetupModalSetState?.call(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load popular movies and people here where we can access Localizations
    _loadPopularMovies();
    _loadRecentlyReleasedMovies();
    _loadPopularTVShows();
    _loadTrendingNewTVShows();
    _loadMostAnticipatedShows();
    _loadMostAnticipatedMovies();
    _loadPopularPeople();
    _loadSonarrAiringNext();
  }

  Future<void> _syncDeepCutsIfNeeded() async {
    // Guard to ensure this only runs once
    if (_deepCutsSyncInitialized || !ZagreusMega.isEnabled) return;
    _deepCutsSyncInitialized = true;

    try {
      final deepCutsService = DeepCutsService();
      // Fetch current state once
      final fetchResult = await deepCutsService.fetchRecommendations();

      // Check if regeneration is needed based on fetched data
      final needsRegen = deepCutsService.needsRegeneration(
        existingResult: fetchResult,
      );

      if (needsRegen) {
        ZagLogger().debug('Deep Cuts need regeneration - triggering...');
        // Fire and forget - don't await
        deepCutsService.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Deep Cuts sync check failed', e, stack);
    }
  }

  Future<void> _syncUpNextIfNeeded() async {
    // Guard to ensure this only runs once
    if (_upNextSyncInitialized || !ZagreusMega.isEnabled) return;
    _upNextSyncInitialized = true;

    try {
      final upNextService = UpNextService();
      // Fetch current state once
      final fetchResult = await upNextService.fetchRecommendations();

      // Check if regeneration is needed based on fetched data
      final needsRegen = upNextService.needsRegeneration(
        existingResult: fetchResult,
      );

      if (needsRegen) {
        ZagLogger().debug('Up Next need regeneration - triggering...');
        // Fire and forget - don't await
        upNextService.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Up Next sync check failed', e, stack);
    }
  }

  Future<void> _syncMagicMoviesIfNeeded() async {
    if (_magicMoviesSyncInitialized || !ZagreusMega.isEnabled) return;
    _magicMoviesSyncInitialized = true;

    try {
      final service = MagicMoviesService();
      final fetchResult = await service.fetchRecommendations();
      final needsRegen = service.needsRegeneration(existingResult: fetchResult);

      if (needsRegen) {
        ZagLogger().debug('Magic Movies need regeneration - triggering...');
        service.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies sync check failed', e, stack);
    }
  }

  Future<void> _syncMagicMoviesCastCrewIfNeeded() async {
    if (_magicMoviesCastCrewSyncInitialized || !ZagreusMega.isEnabled) return;
    _magicMoviesCastCrewSyncInitialized = true;

    try {
      final service = MagicMoviesCastCrewService();
      final fetchResult = await service.fetchRecommendations();
      final needsRegen = service.needsRegeneration(existingResult: fetchResult);

      if (needsRegen) {
        ZagLogger().debug('Magic Movies Cast & Crew need regeneration - triggering...');
        service.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies Cast & Crew sync check failed', e, stack);
    }
  }

  Future<void> _syncMagicShowsIfNeeded() async {
    if (_magicShowsSyncInitialized || !ZagreusMega.isEnabled) return;
    _magicShowsSyncInitialized = true;

    try {
      final service = MagicShowsService();
      final fetchResult = await service.fetchRecommendations();
      final needsRegen = service.needsRegeneration(existingResult: fetchResult);

      if (needsRegen) {
        ZagLogger().debug('Magic Shows need regeneration - triggering...');
        service.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Shows sync check failed', e, stack);
    }
  }

  Future<void> _syncMagicShowsCastCrewIfNeeded() async {
    if (_magicShowsCastCrewSyncInitialized || !ZagreusMega.isEnabled) return;
    _magicShowsCastCrewSyncInitialized = true;

    try {
      final service = MagicShowsCastCrewService();
      final fetchResult = await service.fetchRecommendations();
      final needsRegen = service.needsRegeneration(existingResult: fetchResult);

      if (needsRegen) {
        ZagLogger().debug('Magic Shows Cast & Crew need regeneration - triggering...');
        service.generateRecommendations();
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Shows Cast & Crew sync check failed', e, stack);
    }
  }

  @override
  void dispose() {
    ZagInstanceContext().removeListener(_onInstanceContextChanged);
    _autoScrollTimer?.cancel();
    for (final controller in _sectionScrollControllers.values) {
      controller.dispose();
    }
    _moviesHeroPageController.dispose();
    _tvHeroPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onInstanceContextChanged() {
    // Reload instance-specific data when the global context changes
    _loadRecentlyDownloaded();
    _loadRecentlyDownloadedShows();
    _loadRecommendedMovies();
    _loadMissingMovies();
    _loadDownloadingSoon();
    _syncDeepCutsIfNeeded();
    _syncUpNextIfNeeded();
    _syncMagicMoviesIfNeeded();
    _syncMagicMoviesCastCrewIfNeeded();
    _syncMagicShowsIfNeeded();
    _syncMagicShowsCastCrewIfNeeded();
    if (mounted) setState(() {});
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
      // Handle separate auto-scroll for movies and TV
      if (_trendingMovies.isNotEmpty && _moviesHeroPageController.hasClients) {
        final nextIndex = (_currentMovieHeroIndex + 1) % _trendingMovies.length;
        _moviesHeroPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      if (_trendingTVShows.isNotEmpty && _tvHeroPageController.hasClients) {
        final nextIndex = (_currentTVHeroIndex + 1) % _trendingTVShows.length;
        _tvHeroPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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
      // Load separate lists for movies and TV shows
      final movieItems = await TMDBApi.getTrending(
        mediaType: 'movie',
        timeWindow: _trendingTimeWindow,
      );

      final tvItems = await TMDBApi.getTrending(
        mediaType: 'tv',
        timeWindow: _trendingTimeWindow,
      );

      // Check against Radarr library if available
      if (mounted) {
        final radarrState = context.read<RadarrState>();
        if (radarrState.enabled && radarrState.movies != null) {
          final movies = await radarrState.movies!;
          for (final item in movieItems) {
            final tmdbId = item['tmdbId'] as int;
            item['inLibrary'] = movies.any((m) => m.tmdbId == tmdbId);
          }
        }

        // Check against Sonarr library if available
        final sonarrState = context.read<SonarrState>();
        if (sonarrState.enabled && sonarrState.api != null) {
          try {
            final sonarrSeries = await sonarrState.api!.series.getAll();
            for (final item in tvItems) {
              final title = item['title'] as String;
              // Check if this show is in Sonarr library by title match
              final inLibrary = sonarrSeries.any((series) {
                return series.title?.toLowerCase() == title.toLowerCase();
              });
              item['inLibrary'] = inLibrary;
            }
          } catch (e) {
            print('📺 Error checking Sonarr library for trending: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _trendingMovies = movieItems;
          _trendingTVShows = tvItems;
          _precachedHeroBackdrops.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          // Precache both movie and TV images
          _precacheHeroImage(_currentMovieHeroIndex, isMovie: true);
          _precacheHeroImage(_currentMovieHeroIndex + 1, isMovie: true);
          _precacheHeroImage(_currentTVHeroIndex, isMovie: false);
          _precacheHeroImage(_currentTVHeroIndex + 1, isMovie: false);
        });
      }
    } catch (e) {
      print('Failed to load trending: $e');
      // Falls back to mock data in the API
    }
  }

  void _precacheHeroImage(int index, {required bool isMovie}) {
    if (!mounted) return;

    final items = isMovie ? _trendingMovies : _trendingTVShows;

    if (index < 0 || index >= items.length) return;
    final url = items[index]['backdrop'] as String?;
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

  Future<void> _loadRecentlyReleasedMovies() async {
    print('🎬 Loading recently released movies...');
    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';
      print('🎬 Using region: $region');

      final movies = await TMDBApi.getRecentlyReleasedMovies(region: region);
      print('🎬 Got ${movies.length} recently released movies from TMDB');

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
          _recentlyReleasedMovies =
              movies.take(10).toList(); // Limit to 10 for the section
        });
        print('🎬 Set ${_recentlyReleasedMovies.length} recently released movies in state');
      }
    } catch (e) {
      print('❌ Error loading recently released movies: $e');
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
      ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB.read();
  bool get _showCalendarTab => ZagreusDatabase.SHOW_CALENDAR_TAB.read();
  bool get _showAgentTab => ZagreusDatabase.SHOW_AGENT_TAB.read();

  List<String> _discoverTabKeys({bool? showLegacyModules, bool? showCalendar}) {
    final includeModules = showLegacyModules ?? _showLegacyModules;
    final includeCalendar = showCalendar ?? _showCalendarTab;
    return [
      if (includeModules) 'modules',
      'movies',
      'shows',
      if (includeCalendar) 'calendar',
      'server',
    ];
  }

  int _initialDiscoverTabIndex() {
    final keys = _discoverTabKeys();
    final stored = ZagreusDatabase.DISCOVER_DEFAULT_TAB.read();
    if (stored != null) {
      final index = keys.indexOf(stored);
      if (index != -1) {
        return index;
      }
    }
    final fallback = keys.first;
    ZagreusDatabase.DISCOVER_DEFAULT_TAB.update(fallback);
    return 0;
  }

  void _ensureDiscoverDefaultTabIsValid() {
    final keys = _discoverTabKeys();
    final stored = ZagreusDatabase.DISCOVER_DEFAULT_TAB.read();
    if (!keys.contains(stored)) {
      ZagreusDatabase.DISCOVER_DEFAULT_TAB.update(keys.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureDiscoverDefaultTabIsValid();
    // Build app bar here so it rebuilds when _currentPageIndex changes
    final appBar = ZagAppBar(
      title: _isSearchActive ? 'Search' : (_isAgentActive ? 'Z Agent' : ZagModule.DISCOVER.title),
      useDrawer: true,
      actions: _buildAppBarActions(),
    );

    return ZagBox.zagreus.listenableBuilder(
      selectItems: const [
        ZagreusDatabase.DISCOVER_SHOW_MODULES_TAB,
        ZagreusDatabase.SHOW_CALENDAR_TAB,
        ZagreusDatabase.SHOW_AGENT_TAB,
      ],
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        module: ZagModule.DISCOVER,
        drawer: ZagDrawer(page: ZagModule.DISCOVER.key),
        appBar: appBar,
        body: _body(),
        bottomNavigationBar: (_isSearchActive || _isAgentActive)
            ? null
            : _DiscoverNavigationBar(
                pageController: _pageController,
                showLegacyModules: _showLegacyModules,
                showCalendar: _showCalendarTab,
                showAgentTab: _showAgentTab,
              ),
      ),
    );
  }

  Widget _body() {
    final enableLegacyModules = _showLegacyModules;
    final enableCalendar = _showCalendarTab;
    final showAgentTab = _showAgentTab;
    final tabs = ZagPageView(
      key: ValueKey('discover_tabs_${enableLegacyModules}_${enableCalendar}_$showAgentTab'),
      controller: _pageController,
      children: [
        if (enableLegacyModules) _modulesPage(),
        _moviesPage(),
        _tvShowsPage(),
        if (enableCalendar) _calendarTab(),
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
                child: ZChatPage(key: _agentChatKey),
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
    final enableCalendar = _showCalendarTab;
    final showAgentTab = _showAgentTab;
    final modulesTabIndex = 0;
    final moviesTabIndex = enableLegacyModules ? 1 : 0;
    final showsTabIndex = enableLegacyModules ? 2 : 1;

    // Calculate calendar and server indices dynamically
    int currentIndex = enableLegacyModules ? 3 : 2;
    final calendarIndex = enableCalendar ? currentIndex : null;
    if (enableCalendar) currentIndex++;
    final serverIndex = currentIndex;

    final isMegaOrUltra = ZagreusMega.isEnabled || ZagreusUltra.isEnabled;
    final isPro = ZagreusPro.isEnabled;

    if (_isSearchActive) {
      return [
        IconButton(
          key: const ValueKey('discover_action_close_search'),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close Search',
          onPressed: _closeSearchOverlay,
        ),
      ];
    }

    if (_isAgentActive) {
      final persistLocal =
          ZagreusDatabase.Z_ASSISTANT_PERSIST_CHAT_HISTORY.read();
      final supabaseSync =
          ZagreusDatabase.Z_ASSISTANT_SUPABASE_CHAT_SYNC.read();

      return [
        IconButton(
          key: const ValueKey('discover_action_agent_info'),
          icon: const Icon(Icons.info_outline),
          onPressed: _showZAgentQuickSetup,
          tooltip: 'Z Agent setup',
        ),
        IconButton(
          key: const ValueKey('discover_action_agent_settings'),
          icon: const Icon(Icons.tune),
          onPressed: _showZAssistantSettings,
          tooltip: 'Z Assistant Settings',
        ),
        if (persistLocal && !supabaseSync)
          IconButton(
            key: const ValueKey('discover_action_agent_clear_chat'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _agentChatKey.currentState?.clearChat(),
            tooltip: 'Clear chat',
          ),
        if (supabaseSync)
          IconButton(
            key: const ValueKey('discover_action_agent_new_conversation'),
            icon: const Icon(Icons.add),
            onPressed: () => _agentChatKey.currentState?.startNewConversation(),
            tooltip: 'New conversation',
          ),
        if (_lastZAssistantStageId != null)
          IconButton(
            key: const ValueKey('discover_action_agent_return_results'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToLastZAssistantResults,
            tooltip: 'Return to Z Assistant Results',
          ),
        IconButton(
          key: const ValueKey('discover_action_agent_close'),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close Agent',
          onPressed: _closeAgentOverlay,
        ),
      ];
    }

    if (calendarIndex != null && _currentPageIndex == calendarIndex) {
      final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
      final radarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
      final sonarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
      final hasInstances = radarrInstances.isNotEmpty || sonarrInstances.isNotEmpty;
      
      return [
        if (hasInstances)
          IconButton(
            key: const ValueKey('discover_action_calendar_filter'),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Instances',
            onPressed: _showCalendarInstanceFilter,
          ),
        SwitchViewAction(
          pageController: _pageController,
          calendarPageIndex: calendarIndex,
        ),
      ];
    }

    final actions = <Widget>[];

    // Show icons based on tier and tab
    if (enableLegacyModules && _currentPageIndex == modulesTabIndex) {
      // Modules tab
      if (isMegaOrUltra) {
        // Mega/Ultra: Show both Agent and Search
        if (showAgentTab) {
          actions.add(
            IconButton(
              key: const ValueKey('discover_action_agent'),
              icon: const Icon(Icons.smart_toy),
              tooltip: 'Z Agent',
              onPressed: _openAgentOverlay,
            ),
          );
        }
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_search_modules'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: _openSearchOverlay,
          ),
        );
      } else if (isPro) {
        // Pro: Show only Search
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_search_modules_pro'),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: _openSearchOverlay,
          ),
        );
      } else {
        // Defensive fallback: Discover is Pro-only, so this shouldn't be reached
        // No app bar actions needed here
      }
    } else if (_currentPageIndex == moviesTabIndex) {
      // Movies tab - add Radarr instance swap if instances exist
      final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
      final radarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
      if (radarrInstances.isNotEmpty) {
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_radarr_instance'),
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Radarr Instance',
            onPressed: () => _showRadarrInstanceSelector(),
          ),
        );
      }
      if (showAgentTab) {
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_agent_movies'),
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Z Agent',
            onPressed: _openAgentOverlay,
          ),
        );
      }
      actions.add(
        IconButton(
          key: const ValueKey('discover_action_search_movies'),
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: _openSearchOverlay,
        ),
      );
    } else if (_currentPageIndex == showsTabIndex) {
      // Shows tab - add Sonarr instance swap if instances exist
      final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
      final sonarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
      if (sonarrInstances.isNotEmpty) {
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_sonarr_instance'),
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Sonarr Instance',
            onPressed: () => _showSonarrInstanceSelector(),
          ),
        );
      }
      if (showAgentTab) {
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_agent_shows'),
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Z Agent',
            onPressed: _openAgentOverlay,
          ),
        );
      }
      actions.add(
        IconButton(
          key: const ValueKey('discover_action_search_shows'),
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: _openSearchOverlay,
        ),
      );
    } else if (_currentPageIndex == serverIndex) {
      // Server tab
      if (showAgentTab) {
        actions.add(
          IconButton(
            key: const ValueKey('discover_action_agent_server'),
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Z Agent',
            onPressed: _openAgentOverlay,
          ),
        );
      }
      actions.add(
        IconButton(
          key: const ValueKey('discover_action_search_server'),
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: _openSearchOverlay,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  void _showRadarrInstanceSelector() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
    final currentInstance = ZagInstanceContext().getActiveInstance('radarr');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Radarr Instance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.RADARR.title
                : '${ZagModule.RADARR.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.RADARR.color)
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(ctx, instanceKey),
            );
          }).toList(),
        ),
      ),
    );
    
    if (!mounted) return;
    if (result == currentInstance) return; // No change
    
    // Update instance and reset state
    ZagInstanceContext().setActiveInstance('radarr', result);
    context.read<RadarrState>().reset();
    
    // Clear cached data and reload everything for Movies tab
    _recentlyDownloaded = [];
    _recommendedMovies = [];
    _missingMovies = [];
    _downloadingSoon = [];
    _magicMoviesFuture = null;
    _magicMoviesCastCrewFuture = null;
    _magicMoviesSyncInitialized = false;
    _magicMoviesCastCrewSyncInitialized = false;
    _deepCutsFuture = null;
    _deepCutsSyncInitialized = false;
    
    setState(() {});
    
    // Reload all Radarr-dependent data
    _loadRecentlyDownloaded();
    _loadRecommendedMovies();
    _loadMissingMovies();
    _loadDownloadingSoon();
    _syncMagicMoviesIfNeeded();
    _syncMagicMoviesCastCrewIfNeeded();
    _syncDeepCutsIfNeeded();
  }

  void _showSonarrInstanceSelector() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
    final currentInstance = ZagInstanceContext().getActiveInstance('sonarr');
    
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Sonarr Instance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.SONARR.title
                : '${ZagModule.SONARR.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.SONARR.color)
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(ctx, instanceKey),
            );
          }).toList(),
        ),
      ),
    );
    
    if (!mounted) return;
    if (result == currentInstance) return; // No change
    
    // Update instance and reset state
    ZagInstanceContext().setActiveInstance('sonarr', result);
    context.read<SonarrState>().reset();
    
    // Clear cached data and reload everything for Shows tab
    _recentlyDownloadedShows = [];
    _airingNextShows = [];
    _magicShowsFuture = null;
    _magicShowsCastCrewFuture = null;
    _magicShowsSyncInitialized = false;
    _magicShowsCastCrewSyncInitialized = false;
    _upNextFuture = null;
    _upNextSyncInitialized = false;
    
    setState(() {});
    
    // Reload all Sonarr-dependent data
    _loadRecentlyDownloadedShows();
    _loadSonarrAiringNext();
    _syncMagicShowsIfNeeded();
    _syncMagicShowsCastCrewIfNeeded();
    _syncUpNextIfNeeded();
  }

  void _showCalendarInstanceFilter() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final radarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
    final sonarrInstances = ZagProfile.getInstancesForModule(currentProfile, 'sonarr');
    
    // Build list of all options: main profiles + instances
    final options = <_CalendarFilterOption>[
      // Main Radarr
      _CalendarFilterOption(
        key: 'radarr:main',
        name: ZagModule.RADARR.title,
        module: ZagModule.RADARR,
        instanceKey: null,
      ),
      // Radarr instances
      ...radarrInstances.map((key) => _CalendarFilterOption(
        key: 'radarr:$key',
        name: '${ZagModule.RADARR.title} ${ZagProfile.getInstanceDisplayName(key) ?? ""}',
        module: ZagModule.RADARR,
        instanceKey: key,
      )),
      // Main Sonarr
      _CalendarFilterOption(
        key: 'sonarr:main',
        name: ZagModule.SONARR.title,
        module: ZagModule.SONARR,
        instanceKey: null,
      ),
      // Sonarr instances
      ...sonarrInstances.map((key) => _CalendarFilterOption(
        key: 'sonarr:$key',
        name: '${ZagModule.SONARR.title} ${ZagProfile.getInstanceDisplayName(key) ?? ""}',
        module: ZagModule.SONARR,
        instanceKey: key,
      )),
    ];
    
    // Get current filter state
    final currentFilter = List<String>.from(
      ZagreusDatabase.CALENDAR_INSTANCE_FILTER.read() ?? []
    );
    
    // If empty, default to all instances selected
    final selectedKeys = currentFilter.isEmpty 
        ? options.map((o) => o.key).toSet()
        : currentFilter.toSet();
    
    await showDialog(
      context: context,
      builder: (ctx) => _CalendarFilterDialog(
        options: options,
        selectedKeys: selectedKeys,
        onSave: (newSelection) {
          // If all selected, save empty list (means "all")
          final allKeys = options.map((o) => o.key).toSet();
          if (newSelection.length == allKeys.length) {
            ZagreusDatabase.CALENDAR_INSTANCE_FILTER.update([]);
          } else {
            ZagreusDatabase.CALENDAR_INSTANCE_FILTER.update(newSelection.toList());
          }
          setState(() {});
        },
      ),
    );
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
          if (_showHeroCarousel)
            _heroCarousel(
              controller: _moviesHeroPageController,
              storageKey: 'discoverHeroCarouselMovies',
              isMovieTab: true,
            ),
          // Content sections in custom order
          ..._buildMovieSections(),
          _discoverSectionsButton(),
          _metadataCredits(),
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
      'recently_released_movies',
      'most_anticipated_movies',
      'popular_people',
      'deep_cuts',
    ];

    // Get saved order or use default
    final savedOrder =
        ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    var sectionOrder =
        savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

    // Migration: Add 'most_anticipated_movies' if missing
    if (!sectionOrder.contains('most_anticipated_movies')) {
      final popularIndex = sectionOrder.indexOf('popular_movies');
      final insertIndex =
          popularIndex == -1 ? sectionOrder.length : popularIndex + 1;
      sectionOrder.insert(insertIndex, 'most_anticipated_movies');
    }

    // Migration: Add 'deep_cuts' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('deep_cuts')) {
      sectionOrder.add('deep_cuts');
      ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(sectionOrder);
    }

    // Migration: Add 'magic_movies' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('magic_movies')) {
      sectionOrder.add('magic_movies');
      ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(sectionOrder);
    }

    // Migration: Add 'magic_movies_cast_crew' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('magic_movies_cast_crew')) {
      sectionOrder.add('magic_movies_cast_crew');
      ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(sectionOrder);
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
      'recently_released_movies': () => Column(children: [
            _recentlyReleasedMoviesSection(),
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
      'magic_movies': () => ZagreusMega.isEnabled
          ? Column(children: [
              _magicMoviesSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
      'magic_movies_cast_crew': () => ZagreusMega.isEnabled
          ? Column(children: [
              _magicMoviesCastCrewSection(),
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
          if (_showHeroCarousel)
            _heroCarousel(
              controller: _tvHeroPageController,
              storageKey: 'discoverHeroCarouselTv',
              isMovieTab: false,
            ),
          // TV shows sections in custom order
          ..._buildTVSections(),
          const SizedBox(height: 16),
          _discoverSectionsButton(),
          _metadataCredits(),
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
      'up_next',
    ];

    // Get saved order or use default
    final savedOrder = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;
    var sectionOrder =
        savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

    // Migration: Add 'up_next' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('up_next')) {
      sectionOrder.add('up_next');
      ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(sectionOrder);
    }

    // Migration: Add 'magic_shows' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('magic_shows')) {
      sectionOrder.add('magic_shows');
      ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(sectionOrder);
    }

    // Migration: Add 'magic_shows_cast_crew' to existing saved orders if missing
    if (savedOrder.isNotEmpty && !sectionOrder.contains('magic_shows_cast_crew')) {
      sectionOrder.add('magic_shows_cast_crew');
      ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(sectionOrder);
    }

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
      'up_next': () => ZagreusMega.isEnabled
          ? Column(children: [
              _upNextSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
      'magic_shows': () => ZagreusMega.isEnabled
          ? Column(children: [
              _magicShowsSection(),
              if (_showTitles) const SizedBox(height: 4)
            ])
          : const SizedBox.shrink(),
      'magic_shows_cast_crew': () => ZagreusMega.isEnabled
          ? Column(children: [
              _magicShowsCastCrewSection(),
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

  Widget _metadataCredits() {
    final textColor = Theme.of(context)
        .textTheme
        .bodySmall
        ?.color
        ?.withOpacity(0.7);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZagUI.DEFAULT_MARGIN_SIZE,
        0,
        ZagUI.DEFAULT_MARGIN_SIZE,
        8,
      ),
      child: Column(
        children: [
          Text(
            'Metadata provided by TMDB, JustWatch, and the Open Movie Database.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _metadataIcon(
                'assets/images/tmdb_long.svg',
                isSvg: true,
                fullWidth: true,
                height: 20,
                gradientOverride: const LinearGradient(
                  colors: [
                    Color(0xFF90CEA1),
                    Color(0xFF01B4E4),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              const SizedBox(height: 8),
              _metadataIcon(
                'assets/images/justwatch_long.png',
                fullWidth: true,
                height: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metadataIcon(
    String assetPath, {
    bool isSvg = false,
    bool fullWidth = false,
    double height = 44,
    Color? colorOverride,
    Gradient? gradientOverride,
  }) {
    Widget image = isSvg
        ? SvgPicture.asset(
            assetPath,
            width: double.infinity,
            height: height,
            fit: BoxFit.contain,
            colorFilter: colorOverride != null && gradientOverride == null
                ? ColorFilter.mode(colorOverride, BlendMode.srcIn)
                : null,
          )
        : Image.asset(
            assetPath,
            width: double.infinity,
            height: height,
            fit: BoxFit.contain,
            color: gradientOverride == null ? colorOverride : null,
          );

    if (gradientOverride != null) {
      image = ShaderMask(
        shaderCallback: (rect) => gradientOverride.createShader(rect),
        blendMode: BlendMode.srcIn,
        child: image,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: image,
    );
  }

  Future<void> _openDiscoverSectionsEditor() async {
    final updated = await showDashboardSectionsEditorSheet(context);
    if (updated == true && mounted) {
      setState(() {
        _loadTrendingTimeWindowSetting();
        _currentMovieHeroIndex = 0;
        _currentTVHeroIndex = 0;
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
      builder: (context, _) => ZagreusDatabase.CALENDAR_INSTANCE_FILTER.listenableBuilder(
        builder: (context, _) {
          // Force rebuild when filter changes
          final filterKey = (ZagreusDatabase.CALENDAR_INSTANCE_FILTER.read() ?? []).join(',');
          return CalendarPage(
            key: ValueKey(
              'discover_calendar_${ZagreusDatabase.ENABLED_PROFILE.read()}_$filterKey',
            ),
          );
        },
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
          var mediaScore = mediaPriority(item);

          // Boost person results when there's a strong name match
          // This ensures exact person matches (e.g., "Marlon Brando") appear at the top
          final mediaType = item['media_type'] as String?;
          if (mediaType == 'person' && matchScore >= 0.88) {
            mediaScore = 1.0;
          }

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
    _persistChatHistory =
        ZagreusDatabase.Z_ASSISTANT_PERSIST_CHAT_HISTORY.read();
    _supabaseChatSync =
        ZagreusDatabase.Z_ASSISTANT_SUPABASE_CHAT_SYNC.read();

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
                        'Turn on these caches so the agent has library and watch history context. Your credentials are never used — all server commands are sent back to your device and processed locally. We also send media path names (including *nix paths), which could potentially be sensitive.',
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 16),
                      ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.listenableBuilder(
                        builder: (context, _) {
                          final enabled =
                              ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.read();
                          return ZagBlock(
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
                                ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.update(value);
                                if (value) {
                                  showZagInfoSnackBar(
                                    title: 'Library Cache Enabled',
                                    message: 'Z Agent will now sync your library periodically',
                                  );
                                } else {
                                  showZagInfoSnackBar(
                                    title: 'Library Cache Disabled',
                                    message: 'Z Agent will no longer sync your library',
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
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
                      ZagreusDatabase.Z_ASSISTANT_PERSIST_CHAT_HISTORY
                          .listenableBuilder(
                        builder: (context, _) {
                          final enabled = ZagreusDatabase
                              .Z_ASSISTANT_PERSIST_CHAT_HISTORY
                              .read();
                          return ZagBlock(
                            title: 'Persist Chat History',
                            body: [
                              TextSpan(
                                text: enabled
                                    ? 'Chat history is stored on this device'
                                    : 'Keep chat stateless unless enabled',
                              ),
                            ],
                            trailing: ZagSwitch(
                              value: enabled,
                              onChanged: (value) {
                                ZagreusDatabase
                                    .Z_ASSISTANT_PERSIST_CHAT_HISTORY
                                    .update(value);
                                setState(() => _persistChatHistory = value);

                                if (value) {
                                  // Mutually exclusive: disable Supabase
                                  ZagreusDatabase
                                      .Z_ASSISTANT_SUPABASE_CHAT_SYNC
                                      .update(false);
                                  _supabaseChatSync = false;
                                  _agentChatKey.currentState
                                      ?.onSupabaseSyncChanged(false);
                                }

                                _agentChatKey.currentState
                                    ?.onPersistenceChanged(value);
                                showZagInfoSnackBar(
                                  title: value
                                      ? 'Persistence Enabled'
                                      : 'Persistence Disabled',
                                  message: value
                                      ? 'Z Agent will keep chat history locally'
                                      : 'Z Agent will act stateless and stop storing chats',
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ZagreusDatabase.Z_ASSISTANT_SUPABASE_CHAT_SYNC
                          .listenableBuilder(
                        builder: (context, _) {
                          final enabled = ZagreusDatabase
                              .Z_ASSISTANT_SUPABASE_CHAT_SYNC
                              .read();
                          return ZagBlock(
                            title: 'Supabase Chats',
                            body: [
                              TextSpan(
                                text: enabled
                                    ? 'Sync chats to Supabase'
                                    : 'Off by default',
                              ),
                            ],
                            trailing: ZagSwitch(
                              value: enabled,
                              onChanged: (value) {
                                ZagreusDatabase
                                    .Z_ASSISTANT_SUPABASE_CHAT_SYNC
                                    .update(value);
                                setState(() => _supabaseChatSync = value);

                                if (value) {
                                  // Mutually exclusive: disable local persistence
                                  ZagreusDatabase
                                      .Z_ASSISTANT_PERSIST_CHAT_HISTORY
                                      .update(false);
                                  _persistChatHistory = false;
                                  _agentChatKey.currentState
                                      ?.onPersistenceChanged(false);
                                }

                                _agentChatKey.currentState
                                    ?.onSupabaseSyncChanged(value);
                                showZagInfoSnackBar(
                                  title: value
                                      ? 'Supabase sync enabled'
                                      : 'Supabase sync disabled',
                                  message: value
                                      ? 'Chats will sync to your account'
                                      : 'Supabase chat sync paused',
                                );
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

  Future<void> _showConversationHistory() async {
    if (!ZagreusDatabase.Z_ASSISTANT_SUPABASE_CHAT_SYNC.read()) return;

    final conversationService = ZConversationService();
    final conversations = await conversationService.listConversations();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Conversation History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // New Chat button
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.of(context).pop();
                _agentChatKey.currentState?.clearChat();
              },
            ),
            const Divider(height: 1),
            // Conversation list
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ListTile(
                          leading: const Icon(Icons.chat),
                          title: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${conversation.messageCount} messages • ${_formatDate(conversation.updatedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Conversation'),
                                  content: const Text(
                                    'Are you sure you want to delete this conversation?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && mounted) {
                                await conversationService.deleteConversation(
                                  conversation.conversationId,
                                );
                                Navigator.of(context).pop();
                                _showConversationHistory(); // Refresh list
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _agentChatKey.currentState?.loadConversation(
                              conversation.conversationId,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
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

  /// Show just the Radarr quick add settings in a bottom sheet
  void _showRadarrQuickAddSettings() {
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
                'Quick Add Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  /// Show just the Sonarr quick add settings in a bottom sheet
  void _showSonarrQuickAddSettings() {
    final currentMonitorType =
        _sonarrMonitorType != null && _sonarrMonitorType!.isNotEmpty
            ? SonarrSeriesMonitorType.values.firstWhere(
                (type) => type.value == _sonarrMonitorType,
                orElse: () => SonarrSeriesMonitorType.ALL,
              )
            : SonarrSeriesMonitorType.ALL;

    final currentSeriesType =
        _sonarrSeriesType != null && _sonarrSeriesType!.isNotEmpty
            ? SonarrSeriesType.values.firstWhere(
                (type) => type.value == _sonarrSeriesType,
                orElse: () => SonarrSeriesType.STANDARD,
              )
            : SonarrSeriesType.STANDARD;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Add Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
                leading: const Icon(Icons.monitor),
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
                leading: const Icon(Icons.tv),
                title: const Text('Series Type'),
                subtitle: Text(currentSeriesType.value?.toUpperCase() ?? 'Standard'),
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
            ],
          ),
        ),
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
                        const SizedBox(height: 4),
                        // Badge, Year, and Rating on one line
                        Row(
                          children: [
                            // Badge first
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
                            if (releaseDate.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  releaseDate.split('-').first,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                            if (mediaType != 'person' && voteAverage > 0) ...[
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
                          ],
                        ),
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
                            maxLines: 4,
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
    required bool isMovieTab,
  }) {
    // Determine which list and index to use
    final items = isMovieTab ? _trendingMovies : _trendingTVShows;
    final currentIndex = isMovieTab ? _currentMovieHeroIndex : _currentTVHeroIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (controller.hasClients) {
        final currentPage =
            controller.page?.round() ?? controller.initialPage;
        if (currentPage != currentIndex) {
          controller.jumpToPage(currentIndex);
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
                  if (isMovieTab) {
                    _currentMovieHeroIndex = index;
                  } else {
                    _currentTVHeroIndex = index;
                  }
                });
                _precacheHeroImage(index + 1, isMovie: isMovieTab);
                _precacheHeroImage(index - 1, isMovie: isMovieTab);
              },
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _handleHeroTap(item),
                  onLongPress: item['inLibrary'] != true
                      ? () {
                          if (isMovieTab) {
                            _showMoviePreview(item);
                          } else {
                            _showTVShowPreview(item);
                          }
                        }
                      : null,
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
                items.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
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
        onLongPress: () => _showMoviePreview(movie),
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

  Widget _recentlyReleasedMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        _sectionTitleRow(
          context: context,
          leadingIcon: Icons.new_releases_rounded,
          leadingIconColor: const Color(0xFF6688FF),
          moduleLabel: 'TMDB',
          moduleLabelColor: const Color(0xFF6688FF),
          title: 'Recently Released',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          onTap: _recentlyReleasedMovies.isNotEmpty
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TMDBRecentlyReleasedMoviesRoute(
                        initialData: _recentlyReleasedMovies,
                      ),
                    ),
                  );
                }
              : null,
          onLongPress: () => _refreshSection(
            scrollKey: _scrollIdRecentlyReleasedMovies,
            loader: _loadRecentlyReleasedMovies,
            sectionLabel: 'Recently Released Movies',
          ),
          showArrow: _recentlyReleasedMovies.isNotEmpty,
        ),
        // Movie list or loading placeholder
        _recentlyReleasedMovies.isNotEmpty
            ? SizedBox(
                height: _posterListHeight,
                child: ListView.builder(
                  key: _recentlyReleasedMoviesListKey,
                  controller:
                      _sectionScrollController(_scrollIdRecentlyReleasedMovies),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recentlyReleasedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _recentlyReleasedMovies[index];
                    return _recentlyReleasedMovieCard(movie);
                  },
                ),
              )
            : Container(
                height: _posterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Loading recently released movies...',
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

  Widget _recentlyReleasedMovieCard(Map<String, dynamic> movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Could navigate to a detail view or add to Radarr
          _handleRecentlyReleasedMovieTap(movie);
        },
        onLongPress: () => _showMoviePreview(movie),
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
                        movie['title'] ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _moduleSectionTitleFontSize - 4,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Future<void> _handleRecentlyReleasedMovieTap(Map<String, dynamic> movie) async {
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
          leadingIcon: Icons.local_fire_department_rounded,
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
        onLongPress: () => _showTVShowPreview(show),
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
        onLongPress: () => _showTVShowPreview(show),
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

  // Helper to get Radarr inline options for quick add
  Future<List<String>> _getRadarrRootFolders() async {
    final radarrState = context.read<RadarrState>();
    final folders = await radarrState.rootFolders;
    return folders?.map((f) => f.path ?? '').where((p) => p.isNotEmpty).toList() ?? [];
  }

  Future<List<({int id, String name})>> _getRadarrQualityProfiles() async {
    final radarrState = context.read<RadarrState>();
    final profiles = await radarrState.api!.qualityProfile.getAll();
    return profiles.map((p) => (id: p.id ?? 0, name: p.name ?? 'Unknown')).toList();
  }

  void _onRadarrRootFolderChanged(String path) {
    setState(() => _radarrRootFolder = path);
    ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(path);
  }

  void _onRadarrQualityProfileChanged(int id, String name) {
    setState(() {
      _radarrQualityProfileId = id;
      _radarrQualityProfileName = name;
    });
    ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(id);
    ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(name);
  }

  // Helper to get Sonarr inline options for quick add
  Future<List<String>> _getSonarrRootFolders() async {
    final sonarrState = context.read<SonarrState>();
    final folders = await sonarrState.rootFolders;
    return folders?.map((f) => f.path ?? '').where((p) => p.isNotEmpty).toList() ?? [];
  }

  Future<List<({int id, String name})>> _getSonarrQualityProfiles() async {
    final sonarrState = context.read<SonarrState>();
    final profiles = await sonarrState.api!.profile.getQualityProfiles();
    return profiles.map((p) => (id: p.id ?? 0, name: p.name ?? 'Unknown')).toList();
  }

  void _onSonarrRootFolderChanged(String path) {
    setState(() => _sonarrRootFolder = path);
    ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.update(path);
  }

  void _onSonarrQualityProfileChanged(int id, String name) {
    setState(() {
      _sonarrQualityProfileId = id;
      _sonarrQualityProfileName = name;
    });
    ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.update(id);
    ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.update(name);
  }

  /// Show movie preview with Add button on long press (for non-library items)
  Future<void> _showMoviePreview(Map<String, dynamic> movie) async {
    final bool inLibrary = movie['inLibrary'] ?? false;
    if (inLibrary) return; // Don't show for items already in library

    final title = movie['title'] as String? ?? 'Movie';
    final overview = movie['overview'] as String? ?? 'No overview available.';
    final tmdbId = movie['tmdbId'] as int?;

    if (tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      title,
      overview,
      onAdd: () => _openMovieInRadarr(tmdbId: tmdbId, title: title),
      alignLeft: true,
      rootFolderValue: _radarrRootFolder,
      qualityProfileValue: _radarrQualityProfileName,
      getRootFolders: _getRadarrRootFolders,
      getQualityProfiles: _getRadarrQualityProfiles,
      onRootFolderChanged: _onRadarrRootFolderChanged,
      onQualityProfileChanged: _onRadarrQualityProfileChanged,
    );
  }

  /// Show TV show preview with Add button on long press (for non-library items)
  Future<void> _showTVShowPreview(Map<String, dynamic> show) async {
    final bool inLibrary = show['inLibrary'] ?? false;
    if (inLibrary) return; // Don't show for items already in library

    final title = show['title'] as String? ?? show['name'] as String? ?? 'TV Show';
    final overview = show['overview'] as String? ?? 'No overview available.';
    final tmdbId = show['tmdbId'] as int?;

    if (tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      title,
      overview,
      onAdd: () => _openTVShowInSonarr(tmdbId: tmdbId, title: title),
      alignLeft: true,
      rootFolderValue: _sonarrRootFolder,
      qualityProfileValue: _sonarrQualityProfileName,
      getRootFolders: _getSonarrRootFolders,
      getQualityProfiles: _getSonarrQualityProfiles,
      onRootFolderChanged: _onSonarrRootFolderChanged,
      onQualityProfileChanged: _onSonarrQualityProfileChanged,
    );
  }

  /// Show preview for typed MagicMovie with Add button
  Future<void> _showMagicMoviePreview(MagicMovie movie) async {
    if (movie.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      movie.title,
      movie.reason,
      onAdd: () => _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title),
      alignLeft: true,
      rootFolderValue: _radarrRootFolder,
      qualityProfileValue: _radarrQualityProfileName,
      getRootFolders: _getRadarrRootFolders,
      getQualityProfiles: _getRadarrQualityProfiles,
      onRootFolderChanged: _onRadarrRootFolderChanged,
      onQualityProfileChanged: _onRadarrQualityProfileChanged,
    );
  }

  /// Show preview for typed DeepCutMovie with Add button
  Future<void> _showDeepCutMoviePreview(DeepCutMovie movie) async {
    if (movie.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      movie.title,
      movie.reason,
      onAdd: () => _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title),
      alignLeft: true,
      rootFolderValue: _radarrRootFolder,
      qualityProfileValue: _radarrQualityProfileName,
      getRootFolders: _getRadarrRootFolders,
      getQualityProfiles: _getRadarrQualityProfiles,
      onRootFolderChanged: _onRadarrRootFolderChanged,
      onQualityProfileChanged: _onRadarrQualityProfileChanged,
    );
  }

  /// Show preview for typed MagicShow with Add button
  Future<void> _showMagicShowPreview(MagicShow show) async {
    if (show.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      show.title,
      show.reason,
      onAdd: () => _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title),
      alignLeft: true,
      rootFolderValue: _sonarrRootFolder,
      qualityProfileValue: _sonarrQualityProfileName,
      getRootFolders: _getSonarrRootFolders,
      getQualityProfiles: _getSonarrQualityProfiles,
      onRootFolderChanged: _onSonarrRootFolderChanged,
      onQualityProfileChanged: _onSonarrQualityProfileChanged,
    );
  }

  /// Show preview for typed UpNextShow with Add button
  Future<void> _showUpNextShowPreview(UpNextShow show) async {
    if (show.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      show.title,
      show.reason,
      onAdd: () => _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title),
      alignLeft: true,
      rootFolderValue: _sonarrRootFolder,
      qualityProfileValue: _sonarrQualityProfileName,
      getRootFolders: _getSonarrRootFolders,
      getQualityProfiles: _getSonarrQualityProfiles,
      onRootFolderChanged: _onSonarrRootFolderChanged,
      onQualityProfileChanged: _onSonarrQualityProfileChanged,
    );
  }

  /// Show preview for typed MagicMovieCastCrew with Add button
  Future<void> _showMagicMovieCastCrewPreview(MagicMovieCastCrew movie) async {
    if (movie.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      movie.title,
      movie.reason,
      onAdd: () => _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title),
      alignLeft: true,
      rootFolderValue: _radarrRootFolder,
      qualityProfileValue: _radarrQualityProfileName,
      getRootFolders: _getRadarrRootFolders,
      getQualityProfiles: _getRadarrQualityProfiles,
      onRootFolderChanged: _onRadarrRootFolderChanged,
      onQualityProfileChanged: _onRadarrQualityProfileChanged,
    );
  }

  /// Show preview for typed MagicShowCastCrew with Add button
  Future<void> _showMagicShowCastCrewPreview(MagicShowCastCrew show) async {
    if (show.tmdbId == null) return;

    HapticFeedback.lightImpact();
    await ZagDialogs().textPreviewWithAdd(
      context,
      show.title,
      show.reason,
      onAdd: () => _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title),
      alignLeft: true,
      rootFolderValue: _sonarrRootFolder,
      qualityProfileValue: _sonarrQualityProfileName,
      getRootFolders: _getSonarrRootFolders,
      getQualityProfiles: _getSonarrQualityProfiles,
      onRootFolderChanged: _onSonarrRootFolderChanged,
      onQualityProfileChanged: _onSonarrQualityProfileChanged,
    );
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

  Future<void> _openTVShowInSonarr({required int tmdbId, required String title}) async {
    await _openSeriesInSonarr(tmdbId: tmdbId, title: title);
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
        onLongPress: () => _showTVShowPreview(show),
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
        onLongPress: () => _showMoviePreview(movie),
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
        // Only show refresh button if:
        // 1. We have no data yet (empty state) OR
        // 2. We have data but it's time for regeneration (nextGenerationAt has passed)
        // Do NOT show if we have a successful list that's still fresh
        final canRefresh = !futureSnapshot.hasData ||
            !futureSnapshot.data!.success ||
            (futureSnapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(futureSnapshot.data!.nextGenerationAt!));

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
        onLongPress: () => _showDeepCutMoviePreview(movie),
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

  Widget _upNextSection() {
    final upNextService = UpNextService();

    // Initialize future once if not already set
    _upNextFuture ??= upNextService.fetchRecommendations();

    return FutureBuilder<UpNextResult>(
      future: _upNextFuture,
      builder: (context, futureSnapshot) {
        // Only show refresh button if:
        // 1. We have no data yet (empty state) OR
        // 2. We have data but it's time for regeneration (nextGenerationAt has passed)
        // Do NOT show if we have a successful list that's still fresh
        final canRefresh = !futureSnapshot.hasData ||
            !futureSnapshot.data!.success ||
            (futureSnapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(futureSnapshot.data!.nextGenerationAt!));

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
                      'Up Next',
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
                        await upNextService.generateRecommendations(
                            force: true);
                        if (mounted) {
                          setState(() {
                            _upNextFuture =
                                upNextService.fetchRecommendations();
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
                  return _upNextEmptyState(futureSnapshot.data);
                }

                final recommendations = futureSnapshot.data!.recommendations!;

                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    key: _upNextListKey,
                    controller:
                        _sectionScrollController(_scrollIdUpNext),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return _upNextShowCard(recommendations[index]);
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

  Widget _upNextEmptyState(UpNextResult? result) {
    // Determine message based on error type
    String title = 'No recommendations yet';
    String message = 'Tap refresh to generate AI-powered show recommendations';
    IconData icon = Icons.live_tv_rounded;

    if (result != null && !result.success && result.error != null) {
      switch (result.error!) {
        case UpNextError.notSynced:
          title = 'Library not synced';
          message = result.errorMessage ?? 'Please sync your library first';
          icon = Icons.sync_problem_rounded;
          break;
        case UpNextError.noMegaOrUltra:
          title = 'Mega subscription required';
          message = result.errorMessage ?? 'Up Next requires Mega or Ultra';
          icon = Icons.lock_rounded;
          break;
        case UpNextError.alreadyGenerating:
          title = 'Generation in progress';
          message = result.errorMessage ??
              'Please wait while recommendations are being generated';
          icon = Icons.hourglass_empty_rounded;
          break;
        case UpNextError.fetchFailed:
        case UpNextError.unknown:
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

  Widget _upNextShowCard(UpNextShow show) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          // Use tmdbId from backend if available
          if (show.tmdbId != null) {
            await _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title);
          } else {
            // Fallback: search for the show if no tmdbId
            final tmdbApi = TMDBApi();
            final searchResults =
                await tmdbApi.searchMulti('${show.title} ${show.year}');

            // Filter for TV shows only
            final tvResults =
                searchResults.where((r) => r['media_type'] == 'tv').toList();

            if (tvResults.isNotEmpty) {
              final tmdbId = tvResults.first['id'] as int;
              await _openTVShowInSonarr(tmdbId: tmdbId, title: show.title);
            }
          }
        },
        onLongPress: () => _showUpNextShowPreview(show),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show poster
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  border: show.posterUrl == null
                      ? Border.all(
                          color: ZagColours.purple.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                  image: show.posterUrl != null
                      ? DecorationImage(
                          image: NetworkImage(show.posterUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: show.posterUrl == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.live_tv_rounded,
                              size: 48,
                              color: ZagColours.purple.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                show.title,
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
                              '${show.year}',
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
                show.reason,
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

  // Magic Movies Section
  Widget _magicMoviesSection() {
    final service = MagicMoviesService();
    _magicMoviesFuture ??= service.fetchRecommendations();

    return FutureBuilder<MagicMoviesResult>(
      future: _magicMoviesFuture,
      builder: (context, snapshot) {
        final canRefresh = !snapshot.hasData ||
            !snapshot.data!.success ||
            (snapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(snapshot.data!.nextGenerationAt!));

        final sectionTitle = snapshot.data?.sectionTitle ?? 'Magic Movies';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.auto_fix_high_rounded, color: ZagColours.purple, size: 20),
                  const SizedBox(width: 8),
                  Text('Z', style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold, color: ZagColours.purple)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(sectionTitle, style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold)),
                  ),
                  if (canRefresh)
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: ZagColours.purple, size: 20),
                      onPressed: () async {
                        await service.generateRecommendations(force: true);
                        if (mounted) setState(() => _magicMoviesFuture = service.fetchRecommendations());
                      },
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 280, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.recommendations == null || snapshot.data!.recommendations!.isEmpty) {
                  return Container(height: 200, child: Center(child: Text('No recommendations yet. Tap refresh!')));
                }
                final recommendations = snapshot.data!.recommendations!;
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    controller: _sectionScrollController(_scrollIdMagicMovies),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) => _buildMagicMovieCard(recommendations[index]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicMovieCard(MagicMovie movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          if (movie.tmdbId != null) {
            await _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title);
          }
        },
        onLongPress: () => _showMagicMoviePreview(movie),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  image: movie.posterUrl != null ? DecorationImage(image: NetworkImage(movie.posterUrl!), fit: BoxFit.cover) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(movie.reason, style: TextStyle(fontSize: 12), maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  // Magic Movies Cast & Crew Section
  Widget _magicMoviesCastCrewSection() {
    final service = MagicMoviesCastCrewService();
    _magicMoviesCastCrewFuture ??= service.fetchRecommendations();

    return FutureBuilder<MagicMoviesCastCrewResult>(
      future: _magicMoviesCastCrewFuture,
      builder: (context, snapshot) {
        final canRefresh = !snapshot.hasData ||
            !snapshot.data!.success ||
            (snapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(snapshot.data!.nextGenerationAt!));

        final sectionTitle = snapshot.data?.sectionTitle ?? 'Magic Movies: Cast & Crew';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: ZagColours.purple, size: 20),
                  const SizedBox(width: 8),
                  Text('Z', style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold, color: ZagColours.purple)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(sectionTitle, style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold)),
                  ),
                  if (canRefresh)
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: ZagColours.purple, size: 20),
                      onPressed: () async {
                        await service.generateRecommendations(force: true);
                        if (mounted) setState(() => _magicMoviesCastCrewFuture = service.fetchRecommendations());
                      },
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 280, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.recommendations == null || snapshot.data!.recommendations!.isEmpty) {
                  return Container(height: 200, child: Center(child: Text('No recommendations yet. Tap refresh!')));
                }
                final recommendations = snapshot.data!.recommendations!;
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    controller: _sectionScrollController(_scrollIdMagicMoviesCastCrew),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) => _buildMagicMovieCastCrewCard(recommendations[index]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicMovieCastCrewCard(MagicMovieCastCrew movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          if (movie.tmdbId != null) {
            await _openMovieInRadarr(tmdbId: movie.tmdbId!, title: movie.title);
          }
        },
        onLongPress: () => _showMagicMovieCastCrewPreview(movie),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  image: movie.posterUrl != null ? DecorationImage(image: NetworkImage(movie.posterUrl!), fit: BoxFit.cover) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(movie.reason, style: TextStyle(fontSize: 12), maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  // Magic Shows Section
  Widget _magicShowsSection() {
    final service = MagicShowsService();
    _magicShowsFuture ??= service.fetchRecommendations();

    return FutureBuilder<MagicShowsResult>(
      future: _magicShowsFuture,
      builder: (context, snapshot) {
        final canRefresh = !snapshot.hasData ||
            !snapshot.data!.success ||
            (snapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(snapshot.data!.nextGenerationAt!));

        final sectionTitle = snapshot.data?.sectionTitle ?? 'Magic Shows';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.auto_fix_high_rounded, color: ZagColours.purple, size: 20),
                  const SizedBox(width: 8),
                  Text('Z', style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold, color: ZagColours.purple)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(sectionTitle, style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold)),
                  ),
                  if (canRefresh)
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: ZagColours.purple, size: 20),
                      onPressed: () async {
                        await service.generateRecommendations(force: true);
                        if (mounted) setState(() => _magicShowsFuture = service.fetchRecommendations());
                      },
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 280, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.recommendations == null || snapshot.data!.recommendations!.isEmpty) {
                  return Container(height: 200, child: Center(child: Text('No recommendations yet. Tap refresh!')));
                }
                final recommendations = snapshot.data!.recommendations!;
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    controller: _sectionScrollController(_scrollIdMagicShows),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) => _buildMagicShowCard(recommendations[index]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicShowCard(MagicShow show) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          if (show.tmdbId != null) {
            await _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title);
          }
        },
        onLongPress: () => _showMagicShowPreview(show),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  image: show.posterUrl != null ? DecorationImage(image: NetworkImage(show.posterUrl!), fit: BoxFit.cover) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(show.reason, style: TextStyle(fontSize: 12), maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  // Magic Shows Cast & Crew Section
  Widget _magicShowsCastCrewSection() {
    final service = MagicShowsCastCrewService();
    _magicShowsCastCrewFuture ??= service.fetchRecommendations();

    return FutureBuilder<MagicShowsCastCrewResult>(
      future: _magicShowsCastCrewFuture,
      builder: (context, snapshot) {
        final canRefresh = !snapshot.hasData ||
            !snapshot.data!.success ||
            (snapshot.data!.nextGenerationAt != null &&
                DateTime.now().isAfter(snapshot.data!.nextGenerationAt!));

        final sectionTitle = snapshot.data?.sectionTitle ?? 'Magic Shows: Cast & Crew';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: ZagColours.purple, size: 20),
                  const SizedBox(width: 8),
                  Text('Z', style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold, color: ZagColours.purple)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(sectionTitle, style: TextStyle(fontSize: _moduleSectionTitleFontSize, fontWeight: FontWeight.bold)),
                  ),
                  if (canRefresh)
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: ZagColours.purple, size: 20),
                      onPressed: () async {
                        await service.generateRecommendations(force: true);
                        if (mounted) setState(() => _magicShowsCastCrewFuture = service.fetchRecommendations());
                      },
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 280, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.recommendations == null || snapshot.data!.recommendations!.isEmpty) {
                  return Container(height: 200, child: Center(child: Text('No recommendations yet. Tap refresh!')));
                }
                final recommendations = snapshot.data!.recommendations!;
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(left: 16),
                  child: ListView.builder(
                    controller: _sectionScrollController(_scrollIdMagicShowsCastCrew),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) => _buildMagicShowCastCrewCard(recommendations[index]),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicShowCastCrewCard(MagicShowCastCrew show) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () async {
          if (show.tmdbId != null) {
            await _openTVShowInSonarr(tmdbId: show.tmdbId!, title: show.title);
          }
        },
        onLongPress: () => _showMagicShowCastCrewPreview(show),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  image: show.posterUrl != null ? DecorationImage(image: NetworkImage(show.posterUrl!), fit: BoxFit.cover) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(show.reason, style: TextStyle(fontSize: 12), maxLines: 4, overflow: TextOverflow.ellipsis),
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
        onLongPress: movie.id != null
            ? () => _showRadarrMovieActions(movie)
            : (movie.tmdbId != null
                ? () => _showMoviePreview({
                      'title': movie.title ?? '',
                      'overview': movie.overview ?? '',
                      'tmdbId': movie.tmdbId,
                      'inLibrary': false,
                    })
                : null),
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
  final bool showCalendar;
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
    required this.showCalendar,
    required this.showAgentTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      if (showLegacyModules) Icons.workspaces_rounded,
      Icons.movie_rounded,
      Icons.tv_rounded,
      if (showCalendar) Icons.calendar_today_rounded,
      Icons.dns_rounded,
    ];

    final titles = <String>[
      if (showLegacyModules) 'Modules',
      'Movies',
      'Shows',
      if (showCalendar) 'Calendar',
      'Server',
    ];

    final controllers = <ScrollController>[
      if (showLegacyModules) modulesScrollController,
      moviesScrollController,
      showsScrollController,
      if (showCalendar) calendarScrollController,
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
  int _downloadHistoryWeeks = 2; // Default to 2 weeks for better overview
  List<LidarrRecentlyDownloadedAlbum> _lidarrRecentlyDownloaded = [];
  List<ReadarrRecentlyDownloadedBook> _readarrRecentlyDownloaded = [];
  bool _overseerrEnabled = false;
  bool _overseerrLoading = false;
  String? _overseerrError;
  String _overseerrRequestFilter = 'pending';
  bool _isLoading = false;
  String? _error;

  // Tautulli streams state
  List<TautulliSession> _tautulliStreams = [];
  bool _tautulliEnabled = false;
  bool _tautulliLoading = false;
  String? _tautulliError;
  int? _tautulliStreamCount;
  int? _tautulliDirectPlayCount;
  int? _tautulliDirectStreamCount;
  int? _tautulliTranscodeCount;
  int? _tautulliBandwidth;

  @override
  void initState() {
    super.initState();
    _overseerrRequestFilter = UIPreferencesDatabase.OVERSEERR_REQUEST_FILTER.read() as String;
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadDiskSpaces(),
      _loadServerIssues(),
      _loadOverseerrRequests(),
      _loadTautulliStreams(),
      _loadDownloadHistory(),
      _loadLidarrRecentlyDownloaded(),
      _loadReadarrRecentlyDownloaded(),
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
            host: ZagProfile.current.effectiveRadarrHost(),
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
            host: ZagProfile.current.effectiveSonarrHost(),
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
            host: ZagProfile.current.effectiveRadarrHost(),
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
            host: ZagProfile.current.effectiveSonarrHost(),
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
      // Fetch requests using the saved filter preference
      // Note: Client-side filtering is applied in _buildOverseerrSectionWithFilter
      overseerrState.requestsFilter = _overseerrRequestFilter;
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

  Future<void> _loadTautulliStreams() async {
    if (!mounted) return;

    final tautulliState = context.read<TautulliState>();

    if (!tautulliState.enabled) {
      if (!mounted) return;
      setState(() {
        _tautulliEnabled = false;
        _tautulliLoading = false;
        _tautulliError = null;
        _tautulliStreams = [];
      });
      return;
    }

    setState(() {
      _tautulliEnabled = true;
      _tautulliLoading = true;
      _tautulliError = null;
    });

    try {
      final activity = await tautulliState.api!.activity.getActivity();

      if (!mounted) return;
      setState(() {
        _tautulliStreams = activity?.sessions ?? [];
        _tautulliStreamCount = activity?.streamCount;
        _tautulliDirectPlayCount = activity?.streamCountDirectPlay;
        _tautulliDirectStreamCount = activity?.streamCountDirectStream;
        _tautulliTranscodeCount = activity?.streamCountTranscode;
        _tautulliBandwidth = activity?.totalBandwidth;
        _tautulliLoading = false;
      });
    } catch (e) {
      ZagLogger().warning('Failed to fetch Tautulli streams: $e');
      if (!mounted) return;
      setState(() {
        _tautulliError = e.toString();
        _tautulliLoading = false;
        _tautulliStreams = [];
      });
    }
  }

  bool get _shouldShowTautulliStreamsSection =>
      _tautulliEnabled ||
      _tautulliLoading ||
      _tautulliError != null ||
      _tautulliStreams.isNotEmpty;

  Future<void> _loadDownloadHistory() async {
    if (!mounted) return;

    try {
      print('🔍 Loading download history - SABnzbd enabled: ${ZagProfile.current.sabnzbdEnabled}');
      if (ZagProfile.current.sabnzbdEnabled) {
        final sabnzbdApi = SABnzbdAPI.from(ZagProfile.current);
        final historyData = await DownloadHistoryFetcher.fetchSabnzbdDownloadStats(
          api: sabnzbdApi,
          weeksLookBack: _downloadHistoryWeeks, // Use 2 weeks
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

  Future<void> _loadLidarrRecentlyDownloaded() async {
    print('🎵 _loadLidarrRecentlyDownloaded() called');
    if (!mounted) return;

    try {
      print('🎵 Lidarr enabled: ${ZagProfile.current.lidarrEnabled}');
      if (ZagProfile.current.lidarrEnabled) {
        print('🎵 Creating Lidarr API...');
        final api = LidarrAPI.from(ZagProfile.current);
        print('🎵 Fetching Lidarr history...');
        final history = await api.getHistory(
          sortKey: 'date',
          sortDir: 'descending',
          pageSize: 100,
        );
        print('🎵 Got ${history.length} history records');

        // Filter to only downloadImported events and dedupe by album
        final seenAlbumIds = <int>{};
        final albums = <LidarrRecentlyDownloadedAlbum>[];

        for (final record in history) {
          if (record is LidarrHistoryDataDownloadImported &&
              !seenAlbumIds.contains(record.albumID)) {
            seenAlbumIds.add(record.albumID);

            // Get artist name
            final artist = await api.getArtist(record.artistID);

            // Get album cover from Lidarr API
            String? coverUrl;
            try {
              // Construct cover URL from Lidarr API
              // Note: Lidarr uses /mediacover/Album/{albumId} for album covers
              coverUrl = '${ZagProfile.current.effectiveLidarrHost()}/api/v1/mediacover/Album/${record.albumID}/cover.jpg?apikey=${ZagProfile.current.lidarrKey}';
            } catch (e) {
              // Fallback to null if URL construction fails
              coverUrl = null;
            }

            albums.add(LidarrRecentlyDownloadedAlbum(
              albumId: record.albumID,
              artistId: record.artistID,
              albumTitle: record.title,
              artistName: artist.title,
              coverUrl: coverUrl,
              downloadedAt: record.timestampObject ?? DateTime.now(),
            ));

            if (albums.length >= 10) break; // Limit to 10 for card display
          }
        }

        print('🎵 Processed ${albums.length} albums');
        if (!mounted) return;
        setState(() {
          _lidarrRecentlyDownloaded = albums;
        });
        print('🎵 State updated with ${_lidarrRecentlyDownloaded.length} albums');
      } else {
        print('🎵 Lidarr is disabled, skipping');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load Lidarr recently downloaded: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load Lidarr recently downloaded: $e');
      // Fail silently - this is optional data
    }
  }

  Future<void> _loadReadarrRecentlyDownloaded() async {
    print('📚 _loadReadarrRecentlyDownloaded() called');
    if (!mounted) return;

    try {
      print('📚 Readarr enabled: ${ZagProfile.current.readarrEnabled}');
      if (ZagProfile.current.readarrEnabled) {
        print('📚 Creating Readarr API...');
        final api = ReadarrAPI.from(ZagProfile.current);
        print('📚 Fetching Readarr history...');
        final history = await api.getHistory(
          sortKey: 'date',
          sortDir: 'descending',
          pageSize: 100,
        );
        print('📚 Got ${history.length} history records');

        // Filter to only downloadImported events and dedupe by book
        final seenBookIds = <int>{};
        final books = <ReadarrRecentlyDownloadedBook>[];

        for (final record in history) {
          if (record is ReadarrHistoryDataDownloadImported &&
              !seenBookIds.contains(record.bookID)) {
            seenBookIds.add(record.bookID);

            try {
              // Get book details for cover and rating
              final book = await api.getBook(record.bookID);

              // Get cover URL from book images
              String? coverUrl;
              if (book.images != null && book.images!.isNotEmpty) {
                final coverImage = book.images!.firstWhere(
                  (img) => img['coverType'] == 'cover',
                  orElse: () => book.images!.first,
                );
                coverUrl = coverImage['url'] ?? coverImage['remoteUrl'];
              }

              // Fallback: construct cover URL manually if not found
              if (coverUrl == null || coverUrl.isEmpty) {
                coverUrl = '${ZagProfile.current.effectiveReadarrHost()}/api/v1/mediacover/${record.bookID}/cover.jpg?apikey=${ZagProfile.current.readarrKey}';
              }

              books.add(ReadarrRecentlyDownloadedBook(
                bookId: record.bookID,
                authorId: record.authorID,
                bookTitle: book.title,
                authorName: book.authorName,
                coverUrl: coverUrl,
                rating: book.rating,
                downloadedAt: record.timestampObject ?? DateTime.now(),
              ));

              if (books.length >= 10) break; // Limit to 10 for card display
            } catch (e) {
              print('📚 Failed to get book details for ${record.bookID}: $e');
              // Continue to next record if individual book fetch fails
              continue;
            }
          }
        }

        print('📚 Processed ${books.length} books');
        if (!mounted) return;
        setState(() {
          _readarrRecentlyDownloaded = books;
        });
        print('📚 State updated with ${_readarrRecentlyDownloaded.length} books');
      } else {
        print('📚 Readarr is disabled, skipping');
      }
    } catch (e, stackTrace) {
      print('❌ Failed to load Readarr recently downloaded: $e');
      print('❌ Stack trace: $stackTrace');
      ZagLogger().debug('Failed to load Readarr recently downloaded: $e');
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

    // Get section order from database
    final sectionOrder = UIPreferencesDatabase.SECTION_ORDER.read() as List;
    final orderedSections = sectionOrder.isNotEmpty
        ? List<String>.from(sectionOrder)
        : ['server_issues', 'overseerr_requests', 'tautulli_streams', 'disk_space', 'download_history', 'lidarr_recent', 'readarr_recent'];

    print('🎵 Ordered sections: $orderedSections');
    print('🎵 Lidarr enabled: ${ZagProfile.current.lidarrEnabled}');
    print('📚 Readarr enabled: ${ZagProfile.current.readarrEnabled}');

    // Build section widgets (conditionally include based on settings)
    final sectionWidgets = <String, List<Widget>>{
      'server_issues': _buildServerIssuesSection(),
      if (_shouldShowOverseerrSection) 'overseerr_requests': _buildOverseerrSection(),
      if (_shouldShowTautulliStreamsSection) 'tautulli_streams': _buildTautulliStreamsSection(),
      'disk_space': _buildDiskSpaceSection(),
      if (ZagProfile.current.sabnzbdEnabled) 'download_history': _buildDownloadHistorySection(),
      if (ZagProfile.current.lidarrEnabled) 'lidarr_recent': _buildLidarrRecentSection(),
      if (ZagProfile.current.readarrEnabled) 'readarr_recent': _buildReadarrRecentSection(),
    };

    print('🎵 Section widgets keys: ${sectionWidgets.keys.toList()}');

    return RefreshIndicator(
      onRefresh: _loadData,
      color: ZagColours.currentAccent,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Render sections in order
          for (final sectionId in orderedSections)
            if (sectionWidgets.containsKey(sectionId))
              ...sectionWidgets[sectionId]!,
          // Edit Sections Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
              vertical: 8,
            ),
            child: ZagButton(
              type: ZagButtonType.TEXT,
              text: 'Edit Sections',
              icon: Icons.tune_rounded,
              color: ZagColours.currentAccent,
              onTap: _openServerSectionsEditor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServerIssuesSection() {
    if (_serverIssues.isEmpty && !ZagProfile.current.radarrEnabled && !ZagProfile.current.sonarrEnabled) {
      return [];
    }

    return [
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
    ];
  }

  List<Widget> _buildDiskSpaceSection() {
    if (_diskSpaces.isEmpty) {
      return [];
    }

    return [
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? ZagColours.secondary
                : ZagColours.secondaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.black12,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (int i = 0; i < _diskSpaces.length; i++) ...[
                _buildDiskSpaceItem(_diskSpaces[i]),
                if (i < _diskSpaces.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildDiskSpaceItem(RadarrDiskSpace diskSpace) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  diskSpace.zagPath ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                diskSpace.zagPercentageString ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: diskSpace.zagColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 14,
          child: Text(
            diskSpace.zagSpace ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 4,
          child: ZagLinearPercentIndicator(
            compact: true,
            percent: diskSpace.zagPercentage / 100,
            progressColor: diskSpace.zagColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOverseerrSection() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Text(
              'Overseerr Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _overseerrEnabled
                    ? ZagModule.OVERSEERR.color
                    : Colors.grey,
              ),
            ),
            const Spacer(),
            if (_overseerrEnabled)
              _buildFilterSelector(),
          ],
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'Enable Overseerr',
            body: const [
              TextSpan(
                text: 'Turn on Overseerr in Settings to see requests here.',
              ),
            ],
            trailing: const Icon(Icons.settings_rounded),
            onTap: SettingsRoutes.CONFIGURATION_OVERSEERR.go,
          ),
        )
      else if (_overseerrError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: _getEmptyStateTitle(),
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
    ];
  }

  String _getEmptyStateTitle() {
    switch (_overseerrRequestFilter) {
      case 'pending':
        return 'No pending requests';
      case 'approved':
        return 'No approved requests';
      case 'declined':
        return 'No declined requests';
      case 'available':
        return 'No available content';
      case 'processing':
        return 'Nothing processing';
      case 'unavailable':
        return 'No unavailable requests';
      default:
        return 'No requests found';
    }
  }

  Widget _buildFilterSelector() {
    const filterOptions = {
      'pending': 'Pending',
      'approved': 'Approved',
      'declined': 'Declined',
      'available': 'Available',
      'processing': 'Processing',
      'unavailable': 'Unavailable',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _overseerrRequestFilter,
        underline: const SizedBox(),
        isDense: true,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: ZagColours.accentColor(context),
        ),
        items: filterOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (newFilter) {
          if (newFilter == null) return;
          setState(() {
            _overseerrRequestFilter = newFilter;
          });
          UIPreferencesDatabase.OVERSEERR_REQUEST_FILTER.update(newFilter);
          _loadOverseerrRequests();
        },
      ),
    );
  }

  List<Widget> _buildTautulliStreamsSection() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
          children: [
            Text(
              'Tautulli Streams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _tautulliEnabled
                    ? ZagModule.TAUTULLI.color
                    : Colors.grey,
              ),
            ),
            const Spacer(),
            if (_tautulliEnabled && _tautulliStreams.isNotEmpty)
              _buildStreamsSummary(),
          ],
        ),
      ),
      if (_tautulliLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: ZagLoader(),
          ),
        )
      else if (!_tautulliEnabled)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'Enable Tautulli',
            body: const [
              TextSpan(
                text: 'Turn on Tautulli in Settings to see active streams here.',
              ),
            ],
            trailing: const Icon(Icons.settings_rounded),
            onTap: SettingsRoutes.CONFIGURATION_TAUTULLI.go,
          ),
        )
      else if (_tautulliError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'Unable to load streams',
            body: const [
              TextSpan(
                text: 'Tap to retry. We could not reach Tautulli.',
              ),
            ],
            trailing: const Icon(Icons.refresh_rounded),
            onTap: _loadTautulliStreams,
          ),
        )
      else if (_tautulliStreams.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ZagBlock(
            title: 'No Active Streams',
            body: const [
              TextSpan(text: 'Nobody is currently watching anything.'),
            ],
            trailing: const Icon(Icons.play_circle_outline_rounded),
            onTap: () => ZagModule.TAUTULLI.launch(),
          ),
        )
      else
        ..._tautulliStreams
            .map(
              (stream) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TautulliStreamCard(
                  session: stream,
                ),
              ),
            ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildStreamsSummary() {
    final parts = <String>[];

    if (_tautulliDirectPlayCount != null && _tautulliDirectPlayCount! > 0) {
      parts.add('$_tautulliDirectPlayCount Direct Play');
    }
    if (_tautulliDirectStreamCount != null && _tautulliDirectStreamCount! > 0) {
      parts.add('$_tautulliDirectStreamCount Direct Stream');
    }
    if (_tautulliTranscodeCount != null && _tautulliTranscodeCount! > 0) {
      parts.add('$_tautulliTranscodeCount Transcode');
    }

    final summaryText = parts.isEmpty ? '' : parts.join(' • ');
    final bandwidthText = _tautulliBandwidth != null
        ? '${(_tautulliBandwidth! / 1000).toStringAsFixed(1)} Mbps'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.secondary
            : ZagColours.secondaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summaryText.isNotEmpty)
            Text(
              summaryText,
              style: TextStyle(
                fontSize: 12,
                color: ZagColours.accentColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          if (bandwidthText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              bandwidthText,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDownloadHistorySection() {
    return [
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
        periodLabel: DownloadHistoryFetcher.getPeriodLabel(_downloadHistoryWeeks),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildLidarrRecentSection() {
    print('🎵 _buildLidarrRecentSection() called with ${_lidarrRecentlyDownloaded.length} albums');
    return [
      LidarrRecentlyDownloadedCard(
        albums: _lidarrRecentlyDownloaded,
        onSeeAll: () {
          // TODO: Navigate to full Lidarr history page
        },
        onAlbumTap: (album) {
          // TODO: Navigate to album details
        },
      ),
    ];
  }

  List<Widget> _buildReadarrRecentSection() {
    return [
      ReadarrRecentlyDownloadedCard(
        books: _readarrRecentlyDownloaded,
        onSeeAll: () {
          // TODO: Navigate to full Readarr history page
        },
        onBookTap: (book) {
          // TODO: Navigate to book details
        },
      ),
    ];
  }

  Future<void> _openServerSectionsEditor() async {
    final updated = await showServerSectionsEditorSheet(context);
    if (updated == true && mounted) {
      setState(() {
        _loadData();
      });
    }
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


class _CalendarFilterOption {
  final String key;
  final String name;
  final ZagModule module;
  final String? instanceKey;
  
  _CalendarFilterOption({
    required this.key,
    required this.name,
    required this.module,
    this.instanceKey,
  });
}

class _CalendarFilterDialog extends StatefulWidget {
  final List<_CalendarFilterOption> options;
  final Set<String> selectedKeys;
  final void Function(Set<String>) onSave;
  
  const _CalendarFilterDialog({
    required this.options,
    required this.selectedKeys,
    required this.onSave,
  });
  
  @override
  State<_CalendarFilterDialog> createState() => _CalendarFilterDialogState();
}

class _CalendarFilterDialogState extends State<_CalendarFilterDialog> {
  late Set<String> _selected;
  
  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedKeys);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calendar Instances'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instance list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected = _selected.contains(option.key);
                  return CheckboxListTile(
                    title: Text(option.name),
                    secondary: Icon(option.module.icon, color: option.module.color),
                    value: isSelected,
                    activeColor: option.module.color,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(option.key);
                        } else {
                          _selected.remove(option.key);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_selected);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

