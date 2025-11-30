import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/types/list_view_option.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/services/webhook_sync_service.dart';
import 'webhook_manager.dart';

class RadarrState extends ZagModuleState {
  RadarrState() {
    reset();
  }

  @override
  void dispose() {
    _getQueueTimer?.cancel();
    super.dispose();
  }

  @override
  void reset() {
    // Reset stored data
    _movies = null;
    _upcoming = null;
    _missing = null;
    _rootFolders = null;
    _qualityProfiles = null;
    _qualityDefinitions = null;
    _languages = null;
    _tags = null;
    _queue = null;
    // Reinitialize
    resetProfile();
    if (_enabled) {
      fetchRootFolders();
      fetchQualityProfiles();
      fetchQualityDefinitions();
      fetchLanguages();
      fetchTags();
      fetchMovies();
      fetchQueue();
    }
    notifyListeners();
  }

  ///////////////
  /// PROFILE ///
  ///////////////

  /// API handler instance
  RadarrAPI? _api;

  /// Get the API instance
  RadarrAPI? get api => _api;

  /// Is the API enabled?
  bool _enabled = false;
  bool get enabled => _enabled;

  /// Radarr host
  String _host = '';
  String get host => _host;

  /// Radarr API key
  String _apiKey = '';
  String get apiKey => _apiKey;

  /// Headers to attach to all requests
  Map<String, String> _headers = const {};
  Map<String, String> get headers => _headers;

  /// Check if Radarr is properly configured
  bool get isConfigured => _enabled && _host.isNotEmpty && _apiKey.isNotEmpty;

  /// Reset the profile data, reinitializes API instance
  void resetProfile() {
    ZagLogger().debug('RadarrState.resetProfile called');
    ZagProfile _profile = ZagProfile.current;
    // Copy profile into state
    _enabled = _profile.radarrEnabled;
    _host = _profile.effectiveRadarrHost();
    _apiKey = _profile.radarrKey;
    _headers = Map.unmodifiable(_profile.radarrHeaders);

    ZagLogger().debug(
        'Radarr config - Enabled: $_enabled, Host: $_host, Has API Key: ${_apiKey.isNotEmpty}');

    // Create the API instance if Radarr is enabled and configured
    if (_enabled && _host.isNotEmpty && _apiKey.isNotEmpty) {
      try {
        ZagLogger().debug('Creating Radarr API instance...');
        final useSlowMode =
            ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE.read();
        _api = RadarrAPI(
          host: _host,
          apiKey: _apiKey,
          headers: Map<String, dynamic>.from(_headers),
          slowServerMode: useSlowMode,
        );
        ZagLogger().debug('Radarr API instance created successfully');
        // Note: Webhook sync is handled by WebhookSyncService with proper 24h throttling
      } catch (e, stackTrace) {
        ZagLogger()
            .error('Failed to create Radarr API instance', e, stackTrace);
        _api = null;
      }
    } else {
      ZagLogger().debug('Radarr not enabled or not configured properly');
      _api = null;
    }
  }

  /// Sync webhook configuration
  Future<void> _syncWebhook() async {
    ZagLogger().debug('Starting Radarr webhook sync...');
    try {
      if (_api == null) {
        ZagLogger().warning('Cannot sync webhook - Radarr API is null');
        return;
      }

      ZagLogger().debug('Radarr API exists, calling webhook manager...');
      final success = await RadarrWebhookManager.syncWebhook(_api!);
      if (success) {
        ZagLogger().debug('Radarr webhook sync successful!');
        // Update last sync time
        final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
        await WebhookSyncService.manualSync(profileName, 'radarr');
      } else {
        ZagLogger().warning('Radarr webhook sync returned false');
      }
    } catch (e) {
      // Don't fail profile loading if webhook sync fails
      ZagLogger()
          .warning('Failed to sync Radarr webhook during profile load: $e');
    }
  }

  //////////////
  /// MOVIES ///
  //////////////

  String _moviesSearchQuery = '';
  String get moviesSearchQuery => _moviesSearchQuery;
  set moviesSearchQuery(String moviesSearchQuery) {
    _moviesSearchQuery = moviesSearchQuery;
    notifyListeners();
  }

  ZagListViewOption? _moviesViewType =
      RadarrDatabase.DEFAULT_VIEW_MOVIES.read();
  ZagListViewOption get moviesViewType => _moviesViewType!;
  set moviesViewType(ZagListViewOption moviesViewType) {
    _moviesViewType = moviesViewType;
    notifyListeners();
  }

  RadarrMoviesSorting? _moviesSortType =
      RadarrDatabase.DEFAULT_SORTING_MOVIES.read();
  RadarrMoviesSorting get moviesSortType => _moviesSortType!;
  set moviesSortType(RadarrMoviesSorting moviesSortType) {
    _moviesSortType = moviesSortType;
    notifyListeners();
  }

  RadarrMoviesFilter? _moviesFilterType =
      RadarrDatabase.DEFAULT_FILTERING_MOVIES.read();
  RadarrMoviesFilter get moviesFilterType => _moviesFilterType!;
  set moviesFilterType(RadarrMoviesFilter moviesFilterType) {
    _moviesFilterType = moviesFilterType;
    notifyListeners();
  }

  bool? _moviesSortAscending =
      RadarrDatabase.DEFAULT_SORTING_MOVIES_ASCENDING.read();
  bool get moviesSortAscending => _moviesSortAscending!;
  set moviesSortAscending(bool moviesSortAscending) {
    _moviesSortAscending = moviesSortAscending;
    notifyListeners();
  }

  Future<List<RadarrMovie>>? _movies;
  Future<List<RadarrMovie>>? get movies => _movies;
  void fetchMovies() {
    if (_api != null) {
      _movies = _api!.movie.getAll();
      _fetchUpcoming();
      _fetchMissing();
    }
    notifyListeners();
  }

  Future<void> resetSingleMovie(int movieId) async {
    if (_api != null) {
      RadarrMovie movie = await _api!.movie.get(movieId: movieId);
      List<RadarrMovie> allMovies = await _movies!;
      int index = allMovies.indexWhere((m) => m.id == movieId);
      index >= 0 ? allMovies[index] = movie : allMovies.add(movie);
      _fetchUpcoming();
      _fetchMissing();
    }
    notifyListeners();
  }

  Future<void> setSingleMovie(RadarrMovie movie) async {
    List<RadarrMovie> allMovies = await _movies!;
    int index = allMovies.indexWhere((m) => m.id == movie.id);
    index >= 0 ? allMovies[index] = movie : allMovies.add(movie);
    _fetchUpcoming();
    _fetchMissing();
    notifyListeners();
  }

  Future<List<RadarrRootFolder>>? _rootFolders;
  Future<List<RadarrRootFolder>>? get rootFolders => _rootFolders;
  void fetchRootFolders() {
    if (_enabled) _rootFolders = _api!.rootFolder.get();
    notifyListeners();
  }

  ////////////////
  /// UPCOMING ///
  ////////////////

  Future<List<RadarrMovie>>? _upcoming;
  Future<List<RadarrMovie>>? get upcoming => _upcoming;
  void _fetchUpcoming() {
    if (_movies != null)
      _upcoming = _movies!.then((movies) {
        List<RadarrMovie> _missingOnly = movies
            .where((movie) => movie.monitored! && !movie.hasFile!)
            .toList();
        // List of movies not yet released, but in cinemas, sorted by date
        List<RadarrMovie> _notYetReleased = [];
        List<RadarrMovie> _notYetInCinemas = [];
        _missingOnly.forEach((movie) {
          if (movie.zagIsInCinemas && !movie.zagIsReleased)
            _notYetReleased.add(movie);
          if (!movie.zagIsInCinemas && !movie.zagIsReleased)
            _notYetInCinemas.add(movie);
        });
        _notYetReleased.sort((a, b) => a.zagCompareToByReleaseDate(b));
        _notYetInCinemas.sort((a, b) => a.zagCompareToByInCinemas(b));
        // Concat and return full array
        return [
          ..._notYetReleased,
          ..._notYetInCinemas,
        ];
      });
  }

  ///////////////
  /// MISSING ///
  ///////////////

  Future<List<RadarrMovie>>? _missing;
  Future<List<RadarrMovie>>? get missing => _missing;
  void _fetchMissing() {
    if (_movies != null)
      _missing = _movies!.then((movies) {
        List<RadarrMovie> _movies = movies.where((movie) {
          if (!movie.monitored!) return false;
          if (movie.hasFile! || movie.movieFile != null) return false;
          if (!movie.zagIsReleased) return false;
          return true;
        }).toList();
        _movies.sort((a, b) {
          int? _comparison;
          if (a.zagEarlierReleaseDate == null &&
              b.zagEarlierReleaseDate != null) return 1;
          if (b.zagEarlierReleaseDate == null &&
              a.zagEarlierReleaseDate != null) return -1;
          if (a.zagEarlierReleaseDate == null &&
              b.zagEarlierReleaseDate == null) _comparison = 0;
          _comparison ??=
              b.zagEarlierReleaseDate!.compareTo(a.zagEarlierReleaseDate!);
          if (_comparison == 0)
            return a.sortTitle!
                .toLowerCase()
                .compareTo(b.sortTitle!.toLowerCase());
          return _comparison;
        });
        return _movies;
      });
  }

  ////////////////
  /// PROFILES ///
  ////////////////

  Future<List<RadarrQualityProfile>>? _qualityProfiles;
  Future<List<RadarrQualityProfile>>? get qualityProfiles => _qualityProfiles;
  set qualityProfiles(Future<List<RadarrQualityProfile>>? qualityProfiles) {
    _qualityProfiles = qualityProfiles;
    notifyListeners();
  }

  void fetchQualityProfiles() {
    if (_api != null) _qualityProfiles = _api!.qualityProfile.getAll();
    notifyListeners();
  }

  Future<List<RadarrQualityDefinition>>? _qualityDefinitions;
  Future<List<RadarrQualityDefinition>>? get qualityDefinitions =>
      _qualityDefinitions;
  set qualityDefinitions(
      Future<List<RadarrQualityDefinition>>? qualityDefinitions) {
    _qualityDefinitions = qualityDefinitions;
    notifyListeners();
  }

  void fetchQualityDefinitions() {
    if (_api != null)
      _qualityDefinitions = _api!.qualityProfile.getDefinitions();
    notifyListeners();
  }

  Future<List<RadarrLanguage>>? _languages;
  Future<List<RadarrLanguage>>? get languages => _languages;
  set languages(Future<List<RadarrLanguage>>? languages) {
    _languages = languages;
    notifyListeners();
  }

  Future<void> fetchLanguages() async {
    if (_api != null) _languages = _api!.language.getAll();
    notifyListeners();
  }

  ////////////
  /// TAGS ///
  ////////////

  Future<List<RadarrTag>>? _tags;
  Future<List<RadarrTag>>? get tags => _tags;
  set tags(Future<List<RadarrTag>>? tags) {
    _tags = tags;
    notifyListeners();
  }

  void fetchTags() {
    if (_api != null) _tags = _api!.tag.getAll();
    notifyListeners();
  }

  /////////////
  /// QUEUE ///
  /////////////

  /// Timer to handle refreshing queue data
  Timer? _getQueueTimer;

  void createQueueTimer() => _getQueueTimer = Timer.periodic(
        Duration(seconds: RadarrDatabase.QUEUE_REFRESH_RATE.read()),
        (_) => fetchQueue(),
      );

  void cancelQueueTimer() => _getQueueTimer?.cancel();

  Future<RadarrQueue>? _queue;
  Future<RadarrQueue>? get queue => _queue;
  set queue(Future<RadarrQueue>? queue) {
    _queue = queue;
    notifyListeners();
  }

  void fetchQueue() {
    cancelQueueTimer();
    if (_api != null) {
      _queue = _api!.queue.get(
        pageSize: RadarrDatabase.QUEUE_PAGE_SIZE.read(),
        includeUnknownMovieItems: true,
      );
      createQueueTimer();
    }
    notifyListeners();
  }

  //////////////
  /// IMAGES ///
  //////////////

  String? getPosterURL(int? movieId) {
    if (_enabled && movieId != null) {
      String _base = _host.endsWith('/')
          ? '${_host}api/v3/MediaCover'
          : '$_host/api/v3/MediaCover';
      return '$_base/$movieId/poster-500.jpg?apikey=$_apiKey';
    }
    return null;
  }

  String? getFanartURL(int? movieId, {bool highRes = false}) {
    if (_enabled && movieId != null) {
      String _base = _host.endsWith('/')
          ? '${_host}api/v3/MediaCover'
          : '$_host/api/v3/MediaCover';
      return '$_base/$movieId/fanart-360.jpg?apikey=$_apiKey';
    }
    return null;
  }
}
