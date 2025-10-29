import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
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
import 'package:zagreus/modules/discover/routes/z_assistant_results/route.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:zagreus/services/library_sync_service.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/services/deep_cuts_service.dart';
import 'package:zagreus/router/routes/settings.dart';

class DiscoverHomeRoute extends StatefulWidget {
  const DiscoverHomeRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverHomeRoute> createState() => _State();
}

class _State extends State<DiscoverHomeRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ZagPageController _pageController;
  int _currentPageIndex = 0;

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
  List<Map<String, dynamic>> _popularPeople = [];
  bool _isLoading = true;
  String? _error;

  // Hero carousel state
  PageController _heroPageController = PageController();
  int _currentHeroIndex = 0;
  String _trendingTimeWindow = 'day'; // 'day' or 'week'
  List<Map<String, dynamic>> _trendingItems = [];
  Timer? _autoScrollTimer;
  final Set<String> _precachedHeroBackdrops = {};

  // Z Assistant navigation history
  String? _lastZAssistantStageId;

  // Library sync state
  bool _isSyncing = false;

  // Deep Cuts future (cached to avoid refetching on rebuild)
  Future<DeepCutsResult>? _deepCutsFuture;

  @override
  void initState() {
    super.initState();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load popular movies and people here where we can access Localizations
    _loadPopularMovies();
    _loadPopularTVShows();
    _loadTrendingNewTVShows();
    _loadMostAnticipatedShows();
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
    _heroPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_trendingItems.isNotEmpty) {
        final nextIndex = (_currentHeroIndex + 1) % _trendingItems.length;
        _heroPageController.animateToPage(
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

  Future<void> _loadRecentlyDownloaded() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if Radarr is enabled first
      final radarrState = context.read<RadarrState>();
      if (!radarrState.enabled) {
        // If Radarr is not enabled, just use empty list
        setState(() {
          _recentlyDownloaded = [];
          _isLoading = false;
        });
        return;
      }

      final api = radarrState.api;
      if (api == null) {
        // If API not configured, use empty list
        setState(() {
          _recentlyDownloaded = [];
          _isLoading = false;
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
      for (final movieId in movieIds.take(10)) {
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
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
        _recommendedMovies = uniqueMovies.take(10).toList();
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
          _missingMovies = missingMovies.take(10).toList();
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
        _downloadingSoon = downloadingSoon.take(10).toList();
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

      // Filter to only monitored episodes that haven't aired yet and don't have files
      final upcomingEpisodes = calendar.where((episode) {
        return episode.monitored == true &&
            episode.hasFile != true &&
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

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.listenableBuilder(
      builder: (context, _) {
        final libraryCacheEnabled =
            ZagreusDatabase.Z_ASSISTANT_LIBRARY_CACHE_ENABLED.read();
        return ZagScaffold(
          scaffoldKey: _scaffoldKey,
          module: ZagModule.DISCOVER,
          drawer: ZagDrawer(page: ZagModule.DISCOVER.key),
          appBar: ZagAppBar(
            title: 'Discover',
            useDrawer: true,
            actions: _currentPageIndex == 2
                ? [
                    // Sync button on Agent tab (only if library cache is enabled)
                    if (libraryCacheEnabled)
                      IconButton(
                        icon: _isSyncing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )
                            : const Icon(Icons.sync),
                        onPressed: _isSyncing ? null : _forceLibrarySync,
                        tooltip: 'Sync Library',
                      ),
                    if (_lastZAssistantStageId != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _navigateToLastZAssistantResults,
                        tooltip: 'Return to Z Assistant Results',
                      ),
                  ]
                : (_currentPageIndex != 3
                    ? [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Row(
                            children: [
                              _appBarToggleButton('Today', 'day'),
                              const SizedBox(width: 8),
                              _appBarToggleButton('This Week', 'week'),
                            ],
                          ),
                        ),
                      ]
                    : null),
          ),
          body: _body(),
          bottomNavigationBar: _DiscoverNavigationBar(
            pageController: _pageController,
          ),
        );
      },
    );
  }

  Widget _body() {
    return ZagPageView(
      controller: _pageController,
      children: [
        _moviesPage(),
        _tvShowsPage(),
        const ZChatPage(),
        _searchPage(),
      ],
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
        controller: _DiscoverNavigationBar.scrollControllers[0],
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel
          _heroCarousel(),
          // Content sections in custom order
          ..._buildMovieSections(),
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
      'popular_people',
      'deep_cuts',
    ];

    // Get saved order or use default
    final savedOrder =
        ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    final sectionOrder =
        savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

    // Map of section builders
    final sectionBuilders = <String, Widget Function()>{
      'recently_downloaded': () => _recentlyDownloaded.isNotEmpty
          ? Column(children: [
              _recentlyDownloadedSection(),
              const SizedBox(height: 12)
            ])
          : const SizedBox.shrink(),
      'recommended': () => Column(
          children: [_recommendedMoviesSection(), const SizedBox(height: 12)]),
      'missing': () => _missingMovies.isNotEmpty
          ? Column(
              children: [_missingMoviesSection(), const SizedBox(height: 12)])
          : const SizedBox.shrink(),
      'downloading_soon': () => Column(
          children: [_downloadingSoonSection(), const SizedBox(height: 12)]),
      'popular_movies': () => Column(
          children: [_popularMoviesSection(), const SizedBox(height: 12)]),
      'popular_people': () => Column(
          children: [_popularPeopleSection(), const SizedBox(height: 12)]),
      'deep_cuts': () => ZagreusMega.isEnabled
          ? Column(children: [_deepCutsSection(), const SizedBox(height: 12)])
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

  Widget _tvShowsPage() {
    return RefreshIndicator(
      onRefresh: _loadRecentlyDownloadedShows,
      child: ListView(
        controller: _DiscoverNavigationBar.scrollControllers[1],
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel (could be TV shows specific)
          _heroCarousel(),
          // TV shows sections in custom order
          ..._buildTVSections(),
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
      'popular_tv_shows': () => Column(
          children: [_popularTVShowsSection(), const SizedBox(height: 12)]),
      'trending_new_tv_shows': () => Column(
          children: [_trendingNewTVShowsSection(), const SizedBox(height: 12)]),
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

  /*
  Widget _calendarPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 80,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Release calendar will be available here',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
  */

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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ZagColours.currentAccent),
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
            onShowTap: (tmdbId, title, tvdbId) =>
                _openSeriesInSonarr(tmdbId: tmdbId, tvdbId: tvdbId, title: title),
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

    try {
      final result = await LibrarySyncService().syncLibrary(force: true);

      if (mounted) {
        if (result.success) {
          showZagSnackBar(
            title: 'Library Synced',
            message: 'Your library has been synced to Z Assistant',
            type: ZagSnackbarType.SUCCESS,
          );
        } else {
          // Show specific error message based on error type
          String title;
          String message;
          ZagSnackbarType type;

          switch (result.error) {
            case LibrarySyncError.noMega:
              title = 'Sync Not Available';
              message = 'Library sync is only available for Mega subscribers';
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
      }
    }
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
        return Colors.blue;
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
            'Discover',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6688FF),
            ),
          ),
          const SizedBox(height: 10),
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

  Widget _heroCarousel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_heroPageController.hasClients) {
        final currentPage = _heroPageController.page?.round() ??
            _heroPageController.initialPage;
        if (currentPage != _currentHeroIndex) {
          _heroPageController.jumpToPage(_currentHeroIndex);
        }
      }
    });

    return SizedBox(
      height: 450,
      child: Stack(
        children: [
          GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanCancel: () => _restartAutoScroll(),
            onPanEnd: (_) => _restartAutoScroll(),
            child: PageView.builder(
              key: const PageStorageKey('discoverHeroCarousel'),
              controller: _heroPageController,
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
                                    Icon(
                                      Icons.play_circle_fill,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
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
                              style: const TextStyle(
                                fontSize: 32,
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

  Widget _timeWindowToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _toggleButton('Today', 'day'),
          const SizedBox(width: 12),
          _toggleButton('This Week', 'week'),
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

  Widget _appBarToggleButton(String label, String value) {
    final isSelected = _trendingTimeWindow == value;

    return TextButton(
      onPressed: () {
        setState(() {
          _trendingTimeWindow = value;
          _currentHeroIndex = 0;
        });
        _heroPageController.jumpToPage(0);
        _loadTrendingData();
        _restartAutoScroll();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        backgroundColor: isSelected
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05))
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _toggleButton(String label, String value) {
    final isSelected = _trendingTimeWindow == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _trendingTimeWindow = value;
          _currentHeroIndex = 0;
        });
        _heroPageController.jumpToPage(0);
        _loadTrendingData();
        _restartAutoScroll();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey : Colors.grey.shade600),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey : Colors.grey.shade600),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _recommendedMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Movie list or placeholder
        _recommendedMovies.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommendedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _recommendedMovies[index];
                    return _movieCard(movie);
                  },
                ),
              )
            : Container(
                height: 180,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Missing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Movie list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _missingMovies.length,
            itemBuilder: (context, index) {
              final movie = _missingMovies[index];
              return _missingMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _downloadingSoonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Downloading Soon',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // Movie list
        SizedBox(
          height: 220,
          child: _downloadingSoon.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _downloadingSoon.length,
                  itemBuilder: (context, index) {
                    final movie = _downloadingSoon[index];
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: const Color(0xFF6688FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TMDB',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6688FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Popular Movies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_popularMovies.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        // Movie list or loading placeholder
        _popularMovies.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
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
                height: 180,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: 140,
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
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Rating badge
                  if (movie['rating'] != null && movie['rating'] > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.yellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (movie['rating'] as num).toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie['title'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.tv_rounded,
                  color: const Color(0xFF6688FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TMDB',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6688FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Popular TV Shows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_popularTVShows.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        // TV show list or loading placeholder
        _popularTVShows.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
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
                height: 180,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: 140,
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
                  // Rating badge
                  if (rating > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // In-library indicator
                  if (inLibrary)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF35C5F4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // TV show title
              Text(
                show['title'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: const Color(0xFF6688FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TMDB',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6688FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Trending New TV Shows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_trendingNewTVShows.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        // TV show list or loading placeholder
        _trendingNewTVShows.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _trendingNewTVShows.length,
                  itemBuilder: (context, index) {
                    final show = _trendingNewTVShows[index];
                    return _trendingNewTVShowCard(show);
                  },
                ),
              )
            : Container(
                height: 180,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: 140,
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
                  // Rating badge (below NEW badge if present)
                  if (rating > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // In-library indicator
                  if (inLibrary)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF35C5F4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // TV show title
              Text(
                show['title'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        message: 'Connect Radarr to manage movies from Discover.',
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

  Future<void> _openSeriesInSonarr(
      {int? tmdbId, int? tvdbId, String? title}) async {
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: const Color(0xFFED2224),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trakt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFED2224),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Most Anticipated Shows',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_mostAnticipatedShows.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        // TV show list or loading placeholder
        _mostAnticipatedShows.isNotEmpty
            ? SizedBox(
                height: 220,
                child: ListView.builder(
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
                height: 180,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TV show poster with special styling
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: 140,
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
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // In-library indicator
                  if (inLibrary)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF35C5F4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // TV show title
              Text(
                show['title'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  Widget _popularPeopleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  color: const Color(0xFF6688FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'TMDB',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6688FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Popular People',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_popularPeople.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
        // People list or loading placeholder
        _popularPeople.isNotEmpty
            ? SizedBox(
                height: 150,
                child: ListView.builder(
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ZagColours.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Deep Cuts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              // Refresh button
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ZagColours.purple,
                  size: 20,
                ),
                onPressed: () async {
                  await deepCutsService.generateRecommendations(force: true);
                  if (mounted) {
                    setState(() {
                      _deepCutsFuture = deepCutsService.fetchRecommendations();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // Content
        FutureBuilder<DeepCutsResult>(
          future: _deepCutsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 280,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData ||
                !snapshot.data!.success ||
                snapshot.data!.recommendations == null ||
                snapshot.data!.recommendations!.isEmpty) {
              return _deepCutsEmptyState();
            }

            final recommendations = snapshot.data!.recommendations!;

            return Container(
              height: 300,
              padding: const EdgeInsets.only(left: 16),
              child: ListView.builder(
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
  }

  Widget _deepCutsEmptyState() {
    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_rounded,
              size: 48,
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  .withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No deep cuts yet',
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
            Text(
              'Tap refresh to generate AI-powered recommendations',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
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
          // Search for the movie to get TMDB ID
          final tmdbApi = TMDBApi();
          final searchResults =
              await tmdbApi.searchMulti('${movie.title} ${movie.year}');

          // Filter for movies only
          final movieResults = searchResults
              .where((r) => r['media_type'] == 'movie')
              .toList();

          if (movieResults.isNotEmpty) {
            final tmdbId = movieResults.first['id'] as int;
            final title = movie.title;
            await _openMovieInRadarr(tmdbId: tmdbId, title: title);
          }
        },
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster placeholder (we'll search for it)
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ZagColours.purple.withOpacity(0.2),
                  border: Border.all(
                    color: ZagColours.purple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                ),
              ),
              const SizedBox(height: 8),
              // Reason
              Text(
                movie.reason,
                style: TextStyle(
                  fontSize: 12,
                  color: ZagColours.purple.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
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
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster with missing indicator
              Stack(
                children: [
                  // Simplified poster container to match regular movie cards
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey.shade800,
                      child: _buildPosterImage(context, movie),
                    ),
                  ),
                  // Missing badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MISSING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
          width: 140,
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
                      height: 180,
                      width: 140,
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
                ],
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentlyDownloadedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  ZagIcons.RADARR,
                  color: const Color(0xFFFEC333),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Radarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFEC333),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Recently Downloaded',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        // Movie list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentlyDownloaded.length,
            itemBuilder: (context, index) {
              final item = _recentlyDownloaded[index];
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
        child: Container(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Container(
                height: 180,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPosterImage(context, movie),
                ),
              ),
              const SizedBox(height: 8),
              // Movie title
              Text(
                movie.title ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  ZagIcons.SONARR,
                  color: const Color(0xFF35C5F4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sonarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF35C5F4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Recently Downloaded',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        // TV show list with thin cards (limited to 3)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...displayItems.map((episode) => _tvShowCard(episode)).toList(),
              if (_recentlyDownloadedShows.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
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
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF35C5F4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: const Color(0xFF35C5F4),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: const Color(0xFF35C5F4),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GestureDetector(
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
            child: Row(
              children: [
                Icon(
                  ZagIcons.SONARR,
                  color: const Color(0xFF35C5F4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sonarr',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF35C5F4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Airing Next',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
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
                    color: const Color(0xFF35C5F4).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF35C5F4).withOpacity(0.2),
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
              if (_airingNextShows.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
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
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF35C5F4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: const Color(0xFF35C5F4),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: const Color(0xFF35C5F4),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _airingNextCard(Map<String, dynamic> episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 80,
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
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 80,
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatAiringTime(
                              episode['airDateUtc'], episode['network']),
                          style: TextStyle(
                            fontSize: 10,
                            color: ZagColours.currentAccent,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _tvShowCard(Map<String, dynamic> episode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 80,
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
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 80,
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${episode['seasonNumber']}x${episode['episodeNumber'].toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              episode['network'],
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF35C5F4),
                              ),
                            ),
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
  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<IconData> icons = [
    Icons.movie_rounded,
    Icons.tv_rounded,
    Icons.smart_toy, // Robot icon for Agent
    Icons.search_rounded,
  ];

  static const List<String> titles = [
    'Movies',
    'TV Shows',
    'Agent',
    'Search',
  ];

  const _DiscoverNavigationBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: scrollControllers,
      icons: icons,
      titles: titles,
      onTabChange: (index) {
        // All tabs navigate normally within the PageView
      },
    );
  }
}
