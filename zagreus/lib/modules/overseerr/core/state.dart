import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrState extends ZagModuleState {
  OverseerrState() {
    reset();
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
  OverseerrAPI? _api;

  /// Get the API instance
  OverseerrAPI? get api => _api;

  /// Is the API enabled?
  bool _enabled = false;
  bool get enabled => _enabled;

  /// Overseerr host
  String _host = '';
  String get host => _host;

  /// Overseerr API key
  String _apiKey = '';
  String get apiKey => _apiKey;

  /// Headers to attach to all requests
  Map<String, String> _headers = const {};
  Map<String, String> get headers => _headers;

  /// Check if Overseerr is properly configured
  bool get isConfigured =>
      _enabled && _host.isNotEmpty && _apiKey.isNotEmpty;

  /// Reset the profile data, reinitializes API instance
  void resetProfile() {
    ZagLogger().debug('OverseerrState.resetProfile called');
    ZagProfile _profile = ZagProfile.current;
    // Copy profile into state
    _enabled = _profile.overseerrEnabled;
    _host = _profile.effectiveOverseerrHost();
    _apiKey = _profile.overseerrKey;
    _headers = Map.unmodifiable(_profile.overseerrHeaders);

    ZagLogger().debug(
        'Overseerr config - Enabled: $_enabled, Host: $_host, Has API Key: ${_apiKey.isNotEmpty}');

    // Create the API instance if Overseerr is enabled and configured
    if (_enabled && _host.isNotEmpty && _apiKey.isNotEmpty) {
      try {
        ZagLogger().debug('Creating Overseerr API instance...');

        // Create Dio client with custom headers and API key
        final dio = Dio(BaseOptions(
          baseUrl: _host,
          headers: {
            'X-Api-Key': _apiKey,
            ..._headers,
          },
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ));

        _api = OverseerrAPI(dio, baseUrl: _host);
        ZagLogger().debug('Overseerr API instance created successfully');
      } catch (e, stackTrace) {
        ZagLogger()
            .error('Failed to create Overseerr API instance', e, stackTrace);
        _api = null;
      }
    } else {
      ZagLogger().debug('Overseerr not enabled or not configured properly');
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

  List<OverseerrRequest>? _requests;
  List<OverseerrRequest>? get requests => _requests;

  bool _requestsLoading = false;
  bool get requestsLoading => _requestsLoading;

  String? _requestsError;
  String? get requestsError => _requestsError;

  Future<void> fetchRequests() async {
    if (!isConfigured || _api == null) return;

    _requestsLoading = true;
    _requestsError = null;
    notifyListeners();

    try {
      final response = await GetOverseerrRequests(_api!, Dio())(
        filter: _requestsFilter,
        sort: 'added',
      );

      // Enrich requests with media details if missing
      final enrichedRequests = <OverseerrRequest>[];
      for (final request in response.results) {
        try {
          // Check if media details are missing
          if ((request.media.mediaType == 'movie' && request.media.movie == null) ||
              (request.media.mediaType == 'tv' && request.media.series == null)) {
            ZagLogger().debug('Media details missing for request ${request.id}, fetching from TMDB ID ${request.media.tmdbId}');

            // Fetch media details
            if (request.media.mediaType == 'movie') {
              try {
                final movie = await GetOverseerrMovie(_api!, Dio())(movieId: request.media.tmdbId);
                // Create a new media object with the movie details
                final enrichedMedia = OverseerrMedia(
                  downloadStatus: request.media.downloadStatus,
                  downloadStatus4k: request.media.downloadStatus4k,
                  id: request.media.id,
                  mediaType: request.media.mediaType,
                  tmdbId: request.media.tmdbId,
                  tvdbId: request.media.tvdbId,
                  imdbId: request.media.imdbId,
                  status: request.media.status,
                  status4k: request.media.status4k,
                  createdAt: request.media.createdAt,
                  updatedAt: request.media.updatedAt,
                  lastSeasonChange: request.media.lastSeasonChange,
                  mediaAddedAt: request.media.mediaAddedAt,
                  serviceId: request.media.serviceId,
                  serviceId4k: request.media.serviceId4k,
                  externalServiceId: request.media.externalServiceId,
                  externalServiceId4k: request.media.externalServiceId4k,
                  externalServiceSlug: request.media.externalServiceSlug,
                  externalServiceSlug4k: request.media.externalServiceSlug4k,
                  ratingKey: request.media.ratingKey,
                  ratingKey4k: request.media.ratingKey4k,
                  jellyfinMediaId: request.media.jellyfinMediaId,
                  jellyfinMediaId4k: request.media.jellyfinMediaId4k,
                  serviceUrl: request.media.serviceUrl,
                  movie: movie,
                  series: request.media.series,
                );
                // Create enriched request
                final enrichedRequest = OverseerrRequest(
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
                  media: enrichedMedia,
                  seasons: request.seasons,
                  modifiedBy: request.modifiedBy,
                  requestedBy: request.requestedBy,
                  seasonCount: request.seasonCount,
                );
                enrichedRequests.add(enrichedRequest);
                continue;
              } catch (e) {
                ZagLogger().error('Failed to fetch movie details for TMDB ID ${request.media.tmdbId}', e, StackTrace.current);
              }
            } else if (request.media.mediaType == 'tv') {
              try {
                final series = await GetOverseerrSeries(_api!, Dio())(seriesId: request.media.tmdbId);
                // Create a new media object with the series details
                final enrichedMedia = OverseerrMedia(
                  downloadStatus: request.media.downloadStatus,
                  downloadStatus4k: request.media.downloadStatus4k,
                  id: request.media.id,
                  mediaType: request.media.mediaType,
                  tmdbId: request.media.tmdbId,
                  tvdbId: request.media.tvdbId,
                  imdbId: request.media.imdbId,
                  status: request.media.status,
                  status4k: request.media.status4k,
                  createdAt: request.media.createdAt,
                  updatedAt: request.media.updatedAt,
                  lastSeasonChange: request.media.lastSeasonChange,
                  mediaAddedAt: request.media.mediaAddedAt,
                  serviceId: request.media.serviceId,
                  serviceId4k: request.media.serviceId4k,
                  externalServiceId: request.media.externalServiceId,
                  externalServiceId4k: request.media.externalServiceId4k,
                  externalServiceSlug: request.media.externalServiceSlug,
                  externalServiceSlug4k: request.media.externalServiceSlug4k,
                  ratingKey: request.media.ratingKey,
                  ratingKey4k: request.media.ratingKey4k,
                  jellyfinMediaId: request.media.jellyfinMediaId,
                  jellyfinMediaId4k: request.media.jellyfinMediaId4k,
                  serviceUrl: request.media.serviceUrl,
                  movie: request.media.movie,
                  series: series,
                );
                // Create enriched request
                final enrichedRequest = OverseerrRequest(
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
                  media: enrichedMedia,
                  seasons: request.seasons,
                  modifiedBy: request.modifiedBy,
                  requestedBy: request.requestedBy,
                  seasonCount: request.seasonCount,
                );
                enrichedRequests.add(enrichedRequest);
                continue;
              } catch (e) {
                ZagLogger().error('Failed to fetch series details for TMDB ID ${request.media.tmdbId}', e, StackTrace.current);
              }
            }
          }
        } catch (e) {
          ZagLogger().error('Error enriching request ${request.id}', e, StackTrace.current);
        }
        // Add original request if enrichment failed or wasn't needed
        enrichedRequests.add(request);
      }

      _requests = enrichedRequests;
      _requestsError = null;

      // Debug logging
      if (_requests != null && _requests!.isNotEmpty) {
        final firstRequest = _requests!.first;
        ZagLogger().debug('Overseerr Request Debug:');
        ZagLogger().debug('  Request ID: ${firstRequest.id}');
        ZagLogger().debug('  Media Type: ${firstRequest.media.mediaType}');
        ZagLogger().debug('  TMDB ID: ${firstRequest.media.tmdbId}');
        ZagLogger().debug('  Movie object: ${firstRequest.media.movie != null ? "present" : "NULL"}');
        ZagLogger().debug('  Series object: ${firstRequest.media.series != null ? "present" : "NULL"}');
        if (firstRequest.media.movie != null) {
          ZagLogger().debug('  Movie title: ${firstRequest.media.movie!.title}');
          ZagLogger().debug('  Movie poster: ${firstRequest.media.movie!.posterPath}');
        }
        if (firstRequest.media.series != null) {
          ZagLogger().debug('  Series name: ${firstRequest.media.series!.name}');
          ZagLogger().debug('  Series poster: ${firstRequest.media.series!.posterPath}');
        }
      }
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to fetch Overseerr requests', e, stackTrace);
      _requestsError = e.toString();
    } finally {
      _requestsLoading = false;
      notifyListeners();
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

  List<OverseerrIssue>? _issues;
  List<OverseerrIssue>? get issues => _issues;

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
      final response = await GetOverseerrIssues(_api!, Dio())(
        filter: _issuesFilter,
        sort: 'added',
      );

      // Enrich issues with media details if missing
      final enrichedIssues = <OverseerrIssue>[];
      for (final issue in response.results) {
        try {
          // Check if media details are missing
          if ((issue.media.mediaType == 'movie' && issue.media.movie == null) ||
              (issue.media.mediaType == 'tv' && issue.media.series == null)) {
            ZagLogger().debug('Media details missing for issue ${issue.id}, fetching from TMDB ID ${issue.media.tmdbId}');

            // Fetch media details
            if (issue.media.mediaType == 'movie') {
              try {
                final movie = await GetOverseerrMovie(_api!, Dio())(movieId: issue.media.tmdbId);
                // Create a new media object with the movie details
                final enrichedMedia = OverseerrMedia(
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
                final enrichedIssue = OverseerrIssue(
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
                ZagLogger().error('Failed to fetch movie details for TMDB ID ${issue.media.tmdbId}', e, StackTrace.current);
              }
            } else if (issue.media.mediaType == 'tv') {
              try {
                final series = await GetOverseerrSeries(_api!, Dio())(seriesId: issue.media.tmdbId);
                // Create a new media object with the series details
                final enrichedMedia = OverseerrMedia(
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
                final enrichedIssue = OverseerrIssue(
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
                ZagLogger().error('Failed to fetch series details for TMDB ID ${issue.media.tmdbId}', e, StackTrace.current);
              }
            }
          }
        } catch (e) {
          ZagLogger().error('Error enriching issue ${issue.id}', e, StackTrace.current);
        }
        // Add original issue if enrichment failed or wasn't needed
        enrichedIssues.add(issue);
      }

      _issues = enrichedIssues;
      _issuesError = null;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to fetch Overseerr issues', e, stackTrace);
      _issuesError = e.toString();
    } finally {
      _issuesLoading = false;
      notifyListeners();
    }
  }

  //////////////
  /// USERS ///
  //////////////

  List<OverseerrUser>? _users;
  List<OverseerrUser>? get users => _users;

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
      final response = await GetOverseerrUsers(_api!, Dio())(
        sort: 'displayname',
      );
      _users = response.results;
      _usersError = null;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to fetch Overseerr users', e, stackTrace);
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
      await UpdateOverseerrRequest(_api!, Dio())(
        requestId: requestId,
        status: 'approve',
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to approve Overseerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> declineRequest(int requestId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateOverseerrRequest(_api!, Dio())(
        requestId: requestId,
        status: 'decline',
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to decline Overseerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteRequest(int requestId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await DeleteOverseerrRequest(_api!, Dio())(
        requestId: requestId,
      );
      await fetchRequests();
      return true;
    } catch (e, stackTrace) {
      ZagLogger()
          .error('Failed to delete Overseerr request', e, stackTrace);
      return false;
    }
  }

  Future<bool> resolveIssue(int issueId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateOverseerrIssue(_api!, Dio())(
        issueId: issueId,
        status: 'resolved',
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to resolve Overseerr issue', e, stackTrace);
      return false;
    }
  }

  Future<bool> reopenIssue(int issueId) async {
    if (!isConfigured || _api == null) return false;

    try {
      await UpdateOverseerrIssue(_api!, Dio())(
        issueId: issueId,
        status: 'open',
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to reopen Overseerr issue', e, stackTrace);
      return false;
    }
  }

  Future<bool> addComment(int issueId, String comment) async {
    if (!isConfigured || _api == null) return false;

    try {
      await PostOverseerrComment(_api!, Dio())(
        issueId: issueId,
        comment: comment,
      );
      await fetchIssues();
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to add comment to Overseerr issue', e, stackTrace);
      return false;
    }
  }
}
