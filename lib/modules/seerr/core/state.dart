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
    _requestEnrichments.clear();
    _issueEnrichments.clear();
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
  final Set<int> _requestEnrichments = <int>{};
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

  SeerrRequest? _findRequestById(int requestId) {
    final requests = _requests;
    if (requests == null) return null;
    for (final request in requests) {
      if (request.id == requestId) return request;
    }
    return null;
  }

  void enrichRequestMedia(int requestId) {
    if (!isConfigured || _api == null) return;

    final request = _findRequestById(requestId);
    if (request == null || !_shouldEnrichRequestMedia(request)) return;
    if (request.media.tmdbId == 0) return;
    if (!_requestEnrichments.add(requestId)) return;

    unawaited(_enrichRequestMedia(request, _requestsFetchToken));
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

  Future<void> _enrichRequestMedia(
    SeerrRequest request,
    int fetchToken,
  ) async {
    try {
      if (_api == null) return;
      final tmdbId = request.media.tmdbId;
      if (tmdbId == 0) return;

      final api = _api!;
      final client = Dio();
      SeerrMedia? enrichedMedia;

      if (request.media.mediaType == 'movie') {
        final movie = await GetSeerrMovie(api, client)(movieId: tmdbId);
        enrichedMedia = _copySeerrMedia(request.media, movie: movie);
      } else if (request.media.mediaType == 'tv') {
        final series = await GetSeerrSeries(api, client)(seriesId: tmdbId);
        enrichedMedia = _copySeerrMedia(request.media, series: series);
      }

      if (enrichedMedia == null) return;
      if (fetchToken != _requestsFetchToken) return;

      final requests = _requests;
      if (requests == null) return;
      final index = requests.indexWhere((item) => item.id == request.id);
      if (index == -1) return;

      final updatedRequests = List<SeerrRequest>.from(requests);
      final currentRequest = updatedRequests[index];
      if (!_shouldEnrichRequestMedia(currentRequest)) return;
      updatedRequests[index] =
          _copySeerrRequest(currentRequest, enrichedMedia);
      _requests = updatedRequests;
      notifyListeners();
    } catch (e) {
      ZagLogger().warning(
        'Could not enrich request - TMDB ID ${request.media.tmdbId} may have been removed from TMDB',
      );
    } finally {
      _requestEnrichments.remove(request.id);
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

  int _issuesFetchToken = 0;
  final Set<int> _issueEnrichments = <int>{};
  List<SeerrIssue>? _issues;
  List<SeerrIssue>? get issues => _issues;

  bool _issuesLoading = false;
  bool get issuesLoading => _issuesLoading;

  String? _issuesError;
  String? get issuesError => _issuesError;

  Future<void> fetchIssues() async {
    if (!isConfigured || _api == null) return;

    final fetchToken = ++_issuesFetchToken;
    _issuesLoading = true;
    _issuesError = null;
    notifyListeners();

    try {
      final response = await GetSeerrIssues(_api!, Dio())(
        filter: _issuesFilter,
        sort: 'added',
      );

      if (fetchToken != _issuesFetchToken) return;

      _issues = response.results;
      _issuesError = null;
      _issuesLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      if (fetchToken != _issuesFetchToken) return;
      if (e is DioException) {
        _logDioError('getIssues', e);
      } else {
        ZagLogger().error('Failed to fetch Seerr issues', e, stackTrace);
      }
      _issuesError = e.toString();
      _issuesLoading = false;
      notifyListeners();
    }
  }

  bool _shouldEnrichIssueMedia(SeerrIssue issue) {
    if (issue.media.mediaType == 'movie') {
      return issue.media.movie == null;
    }
    if (issue.media.mediaType == 'tv') {
      return issue.media.series == null;
    }
    return false;
  }

  SeerrIssue? _findIssueById(int issueId) {
    final issues = _issues;
    if (issues == null) return null;
    for (final issue in issues) {
      if (issue.id == issueId) return issue;
    }
    return null;
  }

  void enrichIssueMedia(int issueId) {
    if (!isConfigured || _api == null) return;

    final issue = _findIssueById(issueId);
    if (issue == null || !_shouldEnrichIssueMedia(issue)) return;
    if (issue.media.tmdbId == 0) return;
    if (!_issueEnrichments.add(issueId)) return;

    unawaited(_enrichIssueMedia(issue, _issuesFetchToken));
  }

  SeerrIssue _copySeerrIssue(SeerrIssue issue, SeerrMedia media) {
    return SeerrIssue(
      id: issue.id,
      issueType: issue.issueType,
      status: issue.status,
      problemSeason: issue.problemSeason,
      problemEpisode: issue.problemEpisode,
      createdAt: issue.createdAt,
      updatedAt: issue.updatedAt,
      createdBy: issue.createdBy,
      media: media,
      comments: issue.comments,
    );
  }

  Future<void> _enrichIssueMedia(
    SeerrIssue issue,
    int fetchToken,
  ) async {
    try {
      if (_api == null) return;
      final tmdbId = issue.media.tmdbId;
      if (tmdbId == 0) return;

      final api = _api!;
      final client = Dio();
      SeerrMedia? enrichedMedia;

      if (issue.media.mediaType == 'movie') {
        final movie = await GetSeerrMovie(api, client)(movieId: tmdbId);
        enrichedMedia = _copySeerrMedia(issue.media, movie: movie);
      } else if (issue.media.mediaType == 'tv') {
        final series = await GetSeerrSeries(api, client)(seriesId: tmdbId);
        enrichedMedia = _copySeerrMedia(issue.media, series: series);
      }

      if (enrichedMedia == null) return;
      if (fetchToken != _issuesFetchToken) return;

      final issues = _issues;
      if (issues == null) return;
      final index = issues.indexWhere((item) => item.id == issue.id);
      if (index == -1) return;

      final updatedIssues = List<SeerrIssue>.from(issues);
      final currentIssue = updatedIssues[index];
      if (!_shouldEnrichIssueMedia(currentIssue)) return;
      updatedIssues[index] = _copySeerrIssue(currentIssue, enrichedMedia);
      _issues = updatedIssues;
      notifyListeners();
    } catch (e) {
      ZagLogger().warning(
        'Could not enrich issue - TMDB ID ${issue.media.tmdbId} may have been removed from TMDB',
      );
    } finally {
      _issueEnrichments.remove(issue.id);
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
