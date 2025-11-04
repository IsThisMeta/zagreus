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
    _host = _profile.overseerrHost;
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
      _requests = response.results;
      _requestsError = null;
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
      _issues = response.results;
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
