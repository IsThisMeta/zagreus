import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/seerr.dart';

class SeerrState extends ZagModuleState {
  SeerrState() {
    reset();
  }

  /// Trim whitespace, drop accidental /api(/v1) suffixes, capture basic auth, ensure trailing slash.
  String _normalizeHost(String host) {
    var value = host.trim();
    _basicAuthHeader = null;
    if (value.isEmpty) return value;

    // Capture any userinfo (basic auth) and convert to Authorization header.
    final uri = Uri.tryParse(value);
    if (uri != null && uri.userInfo.isNotEmpty) {
      _basicAuthHeader = 'Basic ${base64Encode(utf8.encode(uri.userInfo))}';
      value = uri.replace(userInfo: '').toString();
    }

    // Remove trailing slashes and accidental /api(/v1) suffixes so we can append our own.
    value = value.replaceAll(RegExp(r'/+$'), '');
    value = value.replaceFirst(RegExp(r'/api(/v1)?/?$'), '');

    return '$value/';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void reset() {
    // Reset stored data
    _requests = null;
    _issues = null;
    _users = null;
    // Reinitialize
    resetProfile();
    if (_enabled) {
      fetchRequests();
      fetchIssues();
      fetchUsers();
    }
    notifyListeners();
  }

  ///////////////
  /// PROFILE ///
  ///////////////

  /// API handler instance
  SeerrAPI? _api;

  /// Get the API instance
  SeerrAPI? get api => _api;

  /// Is the API enabled?
  bool _enabled = false;
  bool get enabled => _enabled;

  /// Seerr host
  String _host = '';
  String get host => _host;

  /// Basic auth header derived from userinfo in the host URL (if provided)
  String? _basicAuthHeader;

  /// Seerr API key
  String _apiKey = '';
  String get apiKey => _apiKey;

  /// Headers to attach to all requests
  Map<String, String> _headers = const {};
  Map<String, String> get headers => _headers;

  /// Check if Seerr is properly configured
  bool get isConfigured =>
      _enabled && _host.isNotEmpty && _apiKey.isNotEmpty;

  /// Reset the profile data, reinitializes API instance
  void resetProfile() {
    ZagLogger().debug('SeerrState.resetProfile called');
    ZagProfile _profile = ZagProfile.forModule('seerr');
    // Copy profile into state
    _enabled = _profile.seerrEnabled;
    _host = _normalizeHost(_profile.effectiveSeerrHost());
    _apiKey = _profile.seerrKey;
    _headers = Map.unmodifiable(_profile.seerrHeaders);

    ZagLogger().debug(
        'Seerr config - Enabled: $_enabled, Host: $_host, Has API Key: ${_apiKey.isNotEmpty}');

    // Create the API instance if Seerr is enabled and configured
    if (_enabled && _host.isNotEmpty && _apiKey.isNotEmpty) {
      try {
        ZagLogger().debug('Creating Seerr API instance...');

        // Create Dio client with custom headers and API key
        final dio = Dio(BaseOptions(
          baseUrl: '${_host}api/',
          headers: {
            if (_basicAuthHeader != null) 'Authorization': _basicAuthHeader!,
            'X-Api-Key': _apiKey,
            'Content-Type': 'application/json',
            ..._headers,
          },
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ));
        dio.interceptors.add(
          InterceptorsWrapper(
            onError: (DioException e, handler) {
              _logDioError('request', e);
              handler.next(e);
            },
          ),
        );

        _api = SeerrAPI(dio);
        ZagLogger().debug('Seerr API instance created successfully');
      } catch (e, stackTrace) {
        ZagLogger()
            .error('Failed to create Seerr API instance', e, stackTrace);
        _api = null;
      }
    } else {
      ZagLogger().debug('Seerr not enabled or not configured properly');
      _api = null;
    }
  }

  ////////////////
  /// REQUESTS ///
  ////////////////

  String _requestsSearchQuery = '';
  String get requestsSearchQuery => _requestsSearchQuery;
  set requestsSearchQuery(String requestsSearchQuery) {
    _requestsSearchQuery = requestsSearchQuery;
    notifyListeners();
  }

  String _requestsFilter = 'pending';
  String get requestsFilter => _requestsFilter;
  set requestsFilter(String requestsFilter) {
    _requestsFilter = requestsFilter;
    notifyListeners();
    fetchRequests();
  }

  String _requestsSort = 'added';
  String get requestsSort => _requestsSort;
  set requestsSort(String requestsSort) {
    _requestsSort = requestsSort;
    notifyListeners();
    fetchRequests();
  }

  int _requestsFetchToken = 0;
  List<SeerrRequest>? _requests;
  List<SeerrRequest>? get requests => _requests;

  bool _requestsLoading = false;
  bool get requestsLoading => _requestsLoading;

  String? _requestsError;
  String? get requestsError => _requestsError;

  Future<void> fetchRequests() async {
    if (!isConfigured || _api == null) return;

    final fetchToken = ++_requestsFetchToken;
    _requestsLoading = true;
    _requestsError = null;
    notifyListeners();

    try {
      final response = await GetSeerrRequests(_api!, Dio())(
        filter: _requestsFilter,
        sort: _requestsSort,
      );

      if (fetchToken != _requestsFetchToken) return;

      _requests = response.results;
      _requestsError = null;
      _requestsLoading = false;
      notifyListeners();

      final needsEnrichment = response.results.any(_shouldEnrichRequestMedia);
      if (needsEnrichment) {
        unawaited(_enrichRequests(response.results, fetchToken));
      } else {
        _logRequestDebug();
      }
    } catch (e, stackTrace) {
      if (fetchToken != _requestsFetchToken) return;
      if (e is DioException) {
        _logDioError('getRequests', e);
      } else {
        ZagLogger().error('Failed to fetch Seerr requests', e, stackTrace);
      }
      _requestsError = e.toString();
      _requestsLoading = false;
      notifyListeners();
    }
  }

  bool _shouldEnrichRequestMedia(SeerrRequest request) {
    if (request.media.mediaType == 'movie') {
      return request.media.movie == null;
    }
    if (request.media.mediaType == 'tv') {
      return request.media.series == null;
    }
    return false;
  }

  SeerrMedia _copySeerrMedia(
    SeerrMedia media, {
    SeerrMovie? movie,
    SeerrSeries? series,
  }) {
    return SeerrMedia(
      downloadStatus: media.downloadStatus,
      downloadStatus4k: media.downloadStatus4k,
      id: media.id,
      mediaType: media.mediaType,
      tmdbId: media.tmdbId,
      tvdbId: media.tvdbId,
      imdbId: media.imdbId,
      status: media.status,
      status4k: media.status4k,
      createdAt: media.createdAt,
      updatedAt: media.updatedAt,
      lastSeasonChange: media.lastSeasonChange,
      mediaAddedAt: media.mediaAddedAt,
      serviceId: media.serviceId,
      serviceId4k: media.serviceId4k,
      externalServiceId: media.externalServiceId,
      externalServiceId4k: media.externalServiceId4k,
      externalServiceSlug: media.externalServiceSlug,
      externalServiceSlug4k: media.externalServiceSlug4k,
      ratingKey: media.ratingKey,
      ratingKey4k: media.ratingKey4k,
      jellyfinMediaId: media.jellyfinMediaId,
      jellyfinMediaId4k: media.jellyfinMediaId4k,
      serviceUrl: media.serviceUrl,
      movie: movie ?? media.movie,
      series: series ?? media.series,
    );
  }

  SeerrRequest _copySeerrRequest(SeerrRequest request, SeerrMedia media) {
    return SeerrRequest(
      id: request.id,
      status: request.status,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      type: request.type,
      is4k: request.is4k,
      serverId: request.serverId,
      profileId: request.profileId,
      rootFolder: request.rootFolder,
      languageProfileId: request.languageProfileId,
      tags: request.tags,
      isAutoRequest: request.isAutoRequest,
      media: media,
      seasons: request.seasons,
      modifiedBy: request.modifiedBy,
      requestedBy: request.requestedBy,
      seasonCount: request.seasonCount,
    );
  }

  Future<void> _enrichRequests(
    List<SeerrRequest> requests,
    int fetchToken,
  ) async {
    if (_api == null || requests.isEmpty) return;

    final api = _api!;
    final client = Dio();
    final movieCache = <int, SeerrMovie>{};
    final seriesCache = <int, SeerrSeries>{};
    final enrichedRequests = List<SeerrRequest>.from(requests);

    for (var i = 0; i < requests.length; i++) {
      if (fetchToken != _requestsFetchToken) return;
      final request = requests[i];
      if (!_shouldEnrichRequestMedia(request)) {
        continue;
      }

      try {
        if (request.media.tmdbId == 0) {
          ZagLogger()
              .debug('Skipping enrichment for request ${request.id} - no valid TMDB ID');
          continue;
        }

        if (request.media.mediaType == 'movie') {
          final tmdbId = request.media.tmdbId;
          final movie =
              movieCache[tmdbId] ?? await GetSeerrMovie(api, client)(movieId: tmdbId);
          movieCache[tmdbId] = movie;
          final enrichedMedia = _copySeerrMedia(
            request.media,
            movie: movie,
          );
          enrichedRequests[i] = _copySeerrRequest(request, enrichedMedia);
        } else if (request.media.mediaType == 'tv') {
          final tmdbId = request.media.tmdbId;
          final series = seriesCache[tmdbId] ??
              await GetSeerrSeries(api, client)(seriesId: tmdbId);
          seriesCache[tmdbId] = series;
          final enrichedMedia = _copySeerrMedia(
            request.media,
            series: series,
          );
          enrichedRequests[i] = _copySeerrRequest(request, enrichedMedia);
        }
      } catch (e) {
        ZagLogger().warning(
          'Could not enrich request - TMDB ID ${request.media.tmdbId} may have been removed from TMDB',
        );
      }
    }

    if (fetchToken != _requestsFetchToken) return;

    _requests = enrichedRequests;
    notifyListeners();
    _logRequestDebug();
  }

  void _logRequestDebug() {
    if (_requests == null || _requests!.isEmpty) return;
    final firstRequest = _requests!.first;
    ZagLogger().debug('Seerr Request Debug:');
    ZagLogger().debug('  Request ID: ${firstRequest.id}');
    ZagLogger().debug('  Media Type: ${firstRequest.media.mediaType}');
    ZagLogger().debug('  TMDB ID: ${firstRequest.media.tmdbId}');
    ZagLogger().debug(
        '  Movie object: ${firstRequest.media.movie != null ? "present" : "NULL"}');
    ZagLogger().debug(
        '  Series object: ${firstRequest.media.series != null ? "present" : "NULL"}');
    if (firstRequest.media.movie != null) {
      ZagLogger().debug('  Movie title: ${firstRequest.media.movie!.title}');
      ZagLogger().debug('  Movie poster: ${firstRequest.media.movie!.posterPath}');
    }
    if (firstRequest.media.series != null) {
      ZagLogger().debug('  Series name: ${firstRequest.media.series!.name}');
      ZagLogger().debug('  Series poster: ${firstRequest.media.series!.posterPath}');
    }
  }

  ///////////////
  /// ISSUES ///
  ///////////////

  String _issuesSearchQuery = '';
  String get issuesSearchQuery => _issuesSearchQuery;
  set issuesSearchQuery(String issuesSearchQuery) {
    _issuesSearchQuery = issuesSearchQuery;
    notifyListeners();
  }

  String _issuesFilter = 'open';
  String get issuesFilter => _issuesFilter;
  set issuesFilter(String issuesFilter) {
    _issuesFilter = issuesFilter;
    notifyListeners();
    fetchIssues();
  }

  List<SeerrIssue>? _issues;
  List<SeerrIssue>? get issues => _issues;

  bool _issuesLoading = false;
  bool get issuesLoading => _issuesLoading;

  String? _issuesError;
  String? get issuesError => _issuesError;

  Future<void> fetchIssues() async {
    if (!isConfigured || _api == null) return;

    _issuesLoading = true;
    _issuesError = null;
    notifyListeners();

    try {
      final response = await GetSeerrIssues(_api!, Dio())(
        filter: _issuesFilter,
        sort: 'added',
      );

      // Enrich issues with media details if missing
      final enrichedIssues = <SeerrIssue>[];
      for (final issue in response.results) {
        try {
          // Skip enrichment if no valid TMDB ID
          if (issue.media.tmdbId == 0) {
            ZagLogger().debug('Skipping enrichment for issue ${issue.id} - no valid TMDB ID');
            enrichedIssues.add(issue);
            continue;
          }

          // Check if media details are missing and fetch them
          if ((issue.media.mediaType == 'movie' && issue.media.movie == null) ||
              (issue.media.mediaType == 'tv' && issue.media.series == null)) {
            // Fetch media details
            if (issue.media.mediaType == 'movie') {
              try {
                final movie = await GetSeerrMovie(_api!, Dio())(movieId: issue.media.tmdbId);
                // Create a new media object with the movie details
                final enrichedMedia = SeerrMedia(
                  downloadStatus: issue.media.downloadStatus,
                  downloadStatus4k: issue.media.downloadStatus4k,
                  id: issue.media.id,
                  mediaType: issue.media.mediaType,
                  tmdbId: issue.media.tmdbId,
                  tvdbId: issue.media.tvdbId,
                  imdbId: issue.media.imdbId,
                  status: issue.media.status,
                  status4k: issue.media.status4k,
                  createdAt: issue.media.createdAt,
                  updatedAt: issue.media.updatedAt,
                  lastSeasonChange: issue.media.lastSeasonChange,
                  mediaAddedAt: issue.media.mediaAddedAt,
                  serviceId: issue.media.serviceId,
                  serviceId4k: issue.media.serviceId4k,
                  externalServiceId: issue.media.externalServiceId,
                  externalServiceId4k: issue.media.externalServiceId4k,
                  externalServiceSlug: issue.media.externalServiceSlug,
                  externalServiceSlug4k: issue.media.externalServiceSlug4k,
                  ratingKey: issue.media.ratingKey,
                  ratingKey4k: issue.media.ratingKey4k,
                  jellyfinMediaId: issue.media.jellyfinMediaId,
                  jellyfinMediaId4k: issue.media.jellyfinMediaId4k,
                  serviceUrl: issue.media.serviceUrl,
                  movie: movie,
                  series: issue.media.series,
                );
                // Create enriched issue
                final enrichedIssue = SeerrIssue(
                  id: issue.id,
                  issueType: issue.issueType,
                  status: issue.status,
                  problemSeason: issue.problemSeason,
                  problemEpisode: issue.problemEpisode,
                  createdAt: issue.createdAt,
                  updatedAt: issue.updatedAt,
                  createdBy: issue.createdBy,
                  media: enrichedMedia,
                  comments: issue.comments,
                );
                enrichedIssues.add(enrichedIssue);
                continue;
              } catch (e) {
                ZagLogger().warning('Could not enrich issue - movie TMDB ID ${issue.media.tmdbId} may have been removed from TMDB');
              }
            } else if (issue.media.mediaType == 'tv') {
              try {
                final series = await GetSeerrSeries(_api!, Dio())(seriesId: issue.media.tmdbId);
                // Create a new media object with the series details
                final enrichedMedia = SeerrMedia(
                  downloadStatus: issue.media.downloadStatus,
                  downloadStatus4k: issue.media.downloadStatus4k,
                  id: issue.media.id,
                  mediaType: issue.media.mediaType,
                  tmdbId: issue.media.tmdbId,
                  tvdbId: issue.media.tvdbId,
                  imdbId: issue.media.imdbId,
                  status: issue.media.status,
                  status4k: issue.media.status4k,
                  createdAt: issue.media.createdAt,
                  updatedAt: issue.media.updatedAt,
                  lastSeasonChange: issue.media.lastSeasonChange,
                  mediaAddedAt: issue.media.mediaAddedAt,
                  serviceId: issue.media.serviceId,
                  serviceId4k: issue.media.serviceId4k,
                  externalServiceId: issue.media.externalServiceId,
                  externalServiceId4k: issue.media.externalServiceId4k,
                  externalServiceSlug: issue.media.externalServiceSlug,
                  externalServiceSlug4k: issue.media.externalServiceSlug4k,
                  ratingKey: issue.media.ratingKey,
                  ratingKey4k: issue.media.ratingKey4k,
                  jellyfinMediaId: issue.media.jellyfinMediaId,
                  jellyfinMediaId4k: issue.media.jellyfinMediaId4k,
                  serviceUrl: issue.media.serviceUrl,
                  movie: issue.media.movie,
                  series: series,
                );
                // Create enriched issue
                final enrichedIssue = SeerrIssue(
                  id: issue.id,
                  issueType: issue.issueType,
                  status: issue.status,
                  problemSeason: issue.problemSeason,
                  problemEpisode: issue.problemEpisode,
                  createdAt: issue.createdAt,
                  updatedAt: issue.updatedAt,
                  createdBy: issue.createdBy,
                  media: enrichedMedia,
                  comments: issue.comments,
                );
                enrichedIssues.add(enrichedIssue);
                continue;
              } catch (e) {
                ZagLogger().warning('Could not enrich issue - series TMDB ID ${issue.media.tmdbId} may have been removed from TMDB');
              }
            }
          }
        } catch (e) {
          ZagLogger().warning('Error enriching issue ${issue.id} - media may have been removed from TMDB');
        }
        // Add original issue if enrichment failed or wasn't needed
        enrichedIssues.add(issue);
      }

      _issues = enrichedIssues;
      _issuesError = null;
    } catch (e, stackTrace) {
      if (e is DioException) {
        _logDioError('getIssues', e);
      } else {
        ZagLogger().error('Failed to fetch Seerr issues', e, stackTrace);
      }
      _issuesError = e.toString();
    } finally {
      _issuesLoading = false;
      notifyListeners();
    }
  }

  //////////////
  /// USERS ///
  //////////////

  List<SeerrUser>? _users;
  List<SeerrUser>? get users => _users;

  bool _usersLoading = false;
  bool get usersLoading => _usersLoading;

  String? _usersError;
  String? get usersError => _usersError;

  Future<void> fetchUsers() async {
    if (!isConfigured || _api == null) return;

    _usersLoading = true;
    _usersError = null;
    notifyListeners();

    try {
      final response = await GetSeerrUsers(_api!, Dio())(
        sort: 'displayname',
      );
      _users = response.results;
      _usersError = null;
    } catch (e, stackTrace) {
      if (e is DioException) {
        _logDioError('getUsers', e);
      } else {
        ZagLogger().error('Failed to fetch Seerr users', e, stackTrace);
      }
      _usersError = e.toString();
    } finally {
      _usersLoading = false;
      notifyListeners();
    }
  }

  ///////////////
  /// ACTIONS ///
  ///////////////

  Future<bool> approveRequest(int requestId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateSeerrRequest(_api!, Dio())(
        requestId: requestId,
        status: 'approve',
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to approve Seerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> declineRequest(int requestId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateSeerrRequest(_api!, Dio())(
        requestId: requestId,
        status: 'decline',
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to decline Seerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteRequest(int requestId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await DeleteSeerrRequest(_api!, Dio())(
        requestId: requestId,
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to delete Seerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> resolveIssue(int issueId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateSeerrIssue(_api!, Dio())(
        issueId: issueId,
        status: 'resolved',
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to resolve Seerr issue', e, stackTrace);
      return false;
    }
  }

  Future<bool> reopenIssue(int issueId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateSeerrIssue(_api!, Dio())(
        issueId: issueId,
        status: 'open',
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to reopen Seerr issue', e, stackTrace);
      return false;
    }
  }

  Future<bool> addComment(int issueId, String comment) async {
    if (!isConfigured || _api == null) return false;

    try {
      await PostSeerrComment(_api!, Dio())(
        issueId: issueId,
        comment: comment,
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to add comment to Seerr issue', e, stackTrace);
      return false;
    }
  }

  void _logDioError(String operation, DioException e) {
    final status = e.response?.statusCode;
    final reason = e.response?.statusMessage;
    final uri = e.requestOptions.uri;
    final method = e.requestOptions.method;
    final msg = StringBuffer('Seerr $operation failed: $method $uri');
    if (status != null) msg.write(' status=$status');
    if (reason?.isNotEmpty ?? false) msg.write(' reason=$reason');
    if (e.message?.isNotEmpty ?? false) msg.write(' message=${e.message}');
    ZagLogger().error(msg.toString(), e, e.stackTrace);

    final data = e.response?.data;
    if (data != null) {
      ZagLogger().debug(
        'Seerr $operation response body: ${_safeDataPreview(data)}',
      );
    }
  }

  String _safeDataPreview(dynamic data, {int limit = 400}) {
    final text = data.toString();
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }
}
