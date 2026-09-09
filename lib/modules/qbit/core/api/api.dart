import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';

class QBitAPI {
  final Dio _dio;
  final String _username;
  final String _password;
  final Map<String, String> _cookies = {};
  bool _basicAuthAccepted = false;
  Future<bool>? _loginFuture;

  QBitAPI._internal(
    this._dio,
    this._username,
    this._password,
  );

  factory QBitAPI.from(ZagProfile profile) {
    final host = profile.effectiveQbitHost().trim();
    final baseUrl = Uri.encodeFull(host.endsWith('/') ? host : '$host/');

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: profile.qbitHeaders,
        followRedirects: true,
        maxRedirects: 5,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
        // API errors are handled centrally so callers never treat 4xx replies
        // as successful mutations.
        validateStatus: (status) => status != null,
      ),
    );

    return QBitAPI._internal(
      dio,
      profile.qbitUser,
      profile.qbitPass,
    );
  }

  bool get _usesApiKey {
    final authorization = _dio.options.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'authorization')
        .map((entry) => entry.value.toString())
        .firstOrNull;
    return authorization?.toLowerCase().startsWith('bearer ') ?? false;
  }

  bool get _hasBasicAuthCredentials =>
      !_usesApiKey && _username.isNotEmpty && _password.isNotEmpty;

  bool get _hasQbitSessionCookie => _cookies.keys.any(_isQbitSessionCookieName);

  String? get _cookieHeader => _cookies.isEmpty
      ? null
      : _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void logError(String text, Object error, StackTrace trace) =>
      ZagLogger().error('qBit: $text', error, trace);

  /// Authenticate and get session cookie
  Future<bool> login() {
    if (_usesApiKey) return Future.value(true);
    return _loginFuture ??= _performLogin().whenComplete(() {
      _loginFuture = null;
    });
  }

  Future<bool> _performLogin() async {
    try {
      var response = await _send(
        'POST',
        'api/v2/auth/login',
        data: {
          'username': _username,
          'password': _password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      if (_requiresBasicAuthRetry(response) && _hasBasicAuthCredentials) {
        response = await _send(
          'POST',
          'api/v2/auth/login',
          data: {
            'username': _username,
            'password': _password,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
            headers: {
              'Authorization': _basicAuthHeader(_username, _password),
            },
          ),
        );
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          _basicAuthAccepted = true;
        }
      }

      _ensureSuccessful(response, 'authenticate');
      final responseBody = response.data?.toString().trim() ?? '';
      if (response.statusCode != 204 && responseBody != 'Ok.') {
        throw QBitApiException(
          operation: 'authenticate',
          statusCode: response.statusCode ?? 0,
          response: responseBody,
        );
      }

      if (!_hasQbitSessionCookie) {
        throw QBitApiException(
          operation: 'authenticate',
          statusCode: response.statusCode ?? 0,
          response:
              'Login succeeded but no qBittorrent session cookie was received',
        );
      }

      return true;
    } catch (error, stack) {
      logError('Failed to login', error, stack);
      rethrow;
    }
  }

  /// Ensure we have a valid session
  Future<void> _ensureSession() async {
    if (!_usesApiKey && !_hasQbitSessionCookie) {
      final success = await login();
      if (!success) {
        throw Exception('Failed to authenticate with qBittorrent');
      }
    }
  }

  Options _authOptions([Options? options]) {
    final opts = options ?? Options();
    opts.headers = {
      ...opts.headers ?? {},
      if (_cookieHeader != null) 'Cookie': _cookieHeader,
      if (_basicAuthAccepted && _hasBasicAuthCredentials)
        'Authorization': _basicAuthHeader(_username, _password),
    };
    return opts;
  }

  /// Build an RFC 7617-compliant Basic Auth header value.
  static String _basicAuthHeader(String user, String pass) {
    final encoded = base64Encode(utf8.encode('$user:$pass'));
    return 'Basic $encoded';
  }

  String _formData(Map<String, Object?> values) => Uri(
        queryParameters: values.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      ).query;

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> _post(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _request('POST', path, data: data, options: options);
  }

  Future<Response<dynamic>> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureSession();

    Future<Response<dynamic>> send() => _send(
          method,
          path,
          data: data,
          queryParameters: queryParameters,
          options: _authOptions(options),
        );

    var response = await send();
    if (!_usesApiKey &&
        (response.statusCode == 401 || response.statusCode == 403)) {
      _clearQbitSessionCookies();
      await _ensureSession();
      response = await send();
    }

    _ensureSuccessful(response, '$method $path');
    return response;
  }

  Future<Response<dynamic>> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    var target = path;
    var includeQueryParameters = true;
    final maxRedirects = _dio.options.maxRedirects;

    for (var redirectCount = 0;; redirectCount++) {
      final response = await _dio.request<dynamic>(
        target,
        data: data,
        queryParameters: includeQueryParameters ? queryParameters : null,
        options: (options ?? Options()).copyWith(
          method: method,
          followRedirects: false,
        ),
      );

      _captureCookies(response);

      if (!_isRedirect(response.statusCode)) return response;

      final location = response.headers.value('location');
      if (location == null || location.isEmpty) return response;
      if (redirectCount >= maxRedirects) {
        throw QBitApiException(
          operation: '$method $path',
          statusCode: response.statusCode ?? 0,
          response: 'Too many redirects',
        );
      }

      final source = response.requestOptions.uri;
      final destination = source.resolve(location);
      if (!_isSafeRedirect(source, destination)) {
        throw QBitApiException(
          operation: '$method $path',
          statusCode: response.statusCode ?? 0,
          response: 'Refused to forward credentials to $destination',
        );
      }

      target = destination.toString();
      includeQueryParameters = false;
    }
  }

  bool _isRedirect(int? statusCode) =>
      statusCode == 301 ||
      statusCode == 302 ||
      statusCode == 307 ||
      statusCode == 308;

  bool _requiresBasicAuthRetry(Response<dynamic> response) =>
      response.statusCode == 401;

  void _captureCookies(Response<dynamic> response) {
    for (final cookie in response.headers['set-cookie'] ?? const <String>[]) {
      final pair = cookie.split(';').first.trim();
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;

      final name = pair.substring(0, separator);
      final value = pair.substring(separator + 1);
      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  void _clearQbitSessionCookies() {
    _cookies.removeWhere((name, _) => _isQbitSessionCookieName(name));
  }

  bool _isQbitSessionCookieName(String name) {
    final normalized = name.toUpperCase();
    return normalized == 'SID' ||
        normalized == 'QBT_SID' ||
        normalized == 'QBIT_SID' ||
        normalized.startsWith('QBT_SID_') ||
        normalized.startsWith('QBIT_SID_');
  }

  bool _isSafeRedirect(Uri source, Uri destination) {
    if (source.host.toLowerCase() != destination.host.toLowerCase()) {
      return false;
    }

    if (source.scheme == destination.scheme) {
      return source.port == destination.port;
    }

    return source.scheme == 'http' && destination.scheme == 'https';
  }

  void _ensureSuccessful(Response<dynamic> response, String operation) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) return;
    throw QBitApiException(
      operation: operation,
      statusCode: status,
      response: response.data?.toString(),
    );
  }

  Future<void> _postWithLegacyFallback({
    required String path,
    required String legacyPath,
    required Object data,
  }) async {
    try {
      await _post(path, data: data);
    } on QBitApiException catch (error) {
      if (error.statusCode != 404 && error.statusCode != 405) rethrow;
      await _post(legacyPath, data: data);
    }
  }

  /// Test connection by getting version
  Future<String> testConnection() async {
    final response = await _get(
      'api/v2/app/version',
      options: Options(responseType: ResponseType.plain),
    );
    return response.data.toString();
  }

  /// Get application version
  Future<String> getVersion() async {
    try {
      final response = await _get(
        'api/v2/app/version',
        options: Options(responseType: ResponseType.plain),
      );
      return response.data.toString();
    } catch (error, stack) {
      logError('Failed to fetch version', error, stack);
      rethrow;
    }
  }

  /// Get transfer info (global stats)
  Future<QBitStatusData> getTransferInfo() async {
    try {
      final response = await _get('api/v2/transfer/info');
      return QBitStatusData.fromJson(response.data);
    } catch (error, stack) {
      logError('Failed to fetch transfer info', error, stack);
      rethrow;
    }
  }

  /// Get all torrents
  Future<List<QBitTorrentData>> getTorrents(
      {String? filter, String? category}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (filter != null) queryParams['filter'] = filter;
      if (category != null) queryParams['category'] = category;

      final response = await _get(
        'api/v2/torrents/info',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<QBitTorrentData> torrents = [];
      for (final torrent in response.data) {
        torrents.add(QBitTorrentData.fromJson(torrent));
      }
      return torrents;
    } catch (error, stack) {
      logError('Failed to fetch torrents', error, stack);
      rethrow;
    }
  }

  /// Get every torrent for the combined queue view.
  Future<List<QBitTorrentData>> getQueue() async {
    return getTorrents();
  }

  /// Get completed torrents (history/seeding)
  Future<List<QBitTorrentData>> getHistory() async {
    final torrents = await getTorrents();
    return torrents.where((t) => t.isCompleted || t.isSeeding).toList();
  }

  /// Get categories
  Future<List<QBitCategoryData>> getCategories() async {
    try {
      final response = await _get('api/v2/torrents/categories');
      return QBitCategoryData.fromCategoriesJson(response.data);
    } catch (error, stack) {
      logError('Failed to fetch categories', error, stack);
      rethrow;
    }
  }

  /// Get torrent files
  Future<List<QBitFileData>> getTorrentFiles(String hash) async {
    try {
      final response = await _get(
        'api/v2/torrents/files',
        queryParameters: {'hash': hash},
      );
      return QBitFileData.fromJsonList(response.data);
    } catch (error, stack) {
      logError('Failed to fetch torrent files', error, stack);
      rethrow;
    }
  }

  /// Get torrent trackers
  Future<List<QBitTrackerData>> getTorrentTrackers(String hash) async {
    try {
      final response = await _get(
        'api/v2/torrents/trackers',
        queryParameters: {'hash': hash},
      );
      return QBitTrackerData.fromJsonList(response.data);
    } catch (error, stack) {
      logError('Failed to fetch torrent trackers', error, stack);
      rethrow;
    }
  }

  /// Pause torrents
  Future<bool> pauseTorrents(List<String> hashes) async {
    try {
      await _postWithLegacyFallback(
        path: 'api/v2/torrents/stop',
        legacyPath: 'api/v2/torrents/pause',
        data: _formData({'hashes': hashes.join('|')}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to pause torrents', error, stack);
      rethrow;
    }
  }

  /// Pause all torrents
  Future<bool> pauseAll() async {
    return pauseTorrents(['all']);
  }

  /// Resume torrents
  Future<bool> resumeTorrents(List<String> hashes) async {
    try {
      await _postWithLegacyFallback(
        path: 'api/v2/torrents/start',
        legacyPath: 'api/v2/torrents/resume',
        data: _formData({'hashes': hashes.join('|')}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to resume torrents', error, stack);
      rethrow;
    }
  }

  /// Resume all torrents
  Future<bool> resumeAll() async {
    return resumeTorrents(['all']);
  }

  /// Delete torrents
  Future<bool> deleteTorrents(List<String> hashes,
      {bool deleteFiles = false}) async {
    try {
      await _post(
        'api/v2/torrents/delete',
        data: _formData({
          'hashes': hashes.join('|'),
          'deleteFiles': deleteFiles,
        }),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to delete torrents', error, stack);
      rethrow;
    }
  }

  /// Add torrent by magnet URL
  Future<bool> addTorrentUrl(String url,
      {String? category, bool? paused}) async {
    try {
      await _post(
        'api/v2/torrents/add',
        data: _formData({
          'urls': url,
          if (category != null && category.isNotEmpty) 'category': category,
          if (paused != null) 'paused': paused,
        }),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to add torrent by URL', error, stack);
      rethrow;
    }
  }

  /// Add torrent by file
  Future<bool> addTorrentFile(List<int> data, String fileName,
      {String? category, bool? paused}) async {
    try {
      final formData = FormData.fromMap({
        'torrents': MultipartFile.fromBytes(data, filename: fileName),
        if (category != null && category.isNotEmpty) 'category': category,
        if (paused != null) 'paused': paused.toString(),
      });

      await _post(
        'api/v2/torrents/add',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to add torrent file', error, stack);
      rethrow;
    }
  }

  /// Set torrent category
  Future<bool> setCategory(List<String> hashes, String category) async {
    try {
      await _post(
        'api/v2/torrents/setCategory',
        data: _formData({
          'hashes': hashes.join('|'),
          'category': category,
        }),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set category', error, stack);
      rethrow;
    }
  }

  /// Set file priority
  Future<bool> setFilePriority(
      String hash, List<int> fileIds, int priority) async {
    try {
      await _post(
        'api/v2/torrents/filePrio',
        data: _formData({
          'hash': hash,
          'id': fileIds.join('|'),
          'priority': priority,
        }),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set file priority', error, stack);
      rethrow;
    }
  }

  /// Recheck torrent
  Future<bool> recheckTorrent(String hash) async {
    try {
      await _post(
        'api/v2/torrents/recheck',
        data: _formData({'hashes': hash}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to recheck torrent', error, stack);
      rethrow;
    }
  }

  /// Reannounce torrent
  Future<bool> reannounceTorrent(String hash) async {
    try {
      await _post(
        'api/v2/torrents/reannounce',
        data: _formData({'hashes': hash}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to reannounce torrent', error, stack);
      rethrow;
    }
  }

  /// Set global download speed limit (0 = unlimited)
  Future<bool> setDownloadSpeedLimit(int limit) async {
    try {
      await _post(
        'api/v2/transfer/setDownloadLimit',
        data: _formData({'limit': limit}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set download speed limit', error, stack);
      rethrow;
    }
  }

  /// Set global upload speed limit (0 = unlimited)
  Future<bool> setUploadSpeedLimit(int limit) async {
    try {
      await _post(
        'api/v2/transfer/setUploadLimit',
        data: _formData({'limit': limit}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set upload speed limit', error, stack);
      rethrow;
    }
  }

  /// Toggle alternative speed limits mode
  Future<bool> toggleSpeedLimitsMode() async {
    try {
      await _post('api/v2/transfer/toggleSpeedLimitsMode');
      return true;
    } catch (error, stack) {
      logError('Failed to toggle speed limits mode', error, stack);
      rethrow;
    }
  }

  /// Rename torrent
  Future<bool> renameTorrent(String hash, String name) async {
    try {
      await _post(
        'api/v2/torrents/rename',
        data: _formData({'hash': hash, 'name': name}),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to rename torrent', error, stack);
      rethrow;
    }
  }

  /// Set torrent location
  Future<bool> setLocation(List<String> hashes, String location) async {
    try {
      await _post(
        'api/v2/torrents/setLocation',
        data: _formData({
          'hashes': hashes.join('|'),
          'location': location,
        }),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set location', error, stack);
      rethrow;
    }
  }

  /// Get torrent properties (detailed info)
  Future<Map<String, dynamic>> getTorrentProperties(String hash) async {
    try {
      final response = await _get(
        'api/v2/torrents/properties',
        queryParameters: {'hash': hash},
      );
      return (response.data as Map).cast<String, dynamic>();
    } catch (error, stack) {
      logError('Failed to fetch torrent properties', error, stack);
      rethrow;
    }
  }
}

class QBitApiException implements Exception {
  final String operation;
  final int statusCode;
  final String? response;

  const QBitApiException({
    required this.operation,
    required this.statusCode,
    this.response,
  });

  @override
  String toString() {
    final details = response == null || response!.isEmpty ? '' : ': $response';
    return 'qBittorrent request failed ($statusCode, $operation)$details';
  }
}
