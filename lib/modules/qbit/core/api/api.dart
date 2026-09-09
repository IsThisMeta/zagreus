import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';

class QBitAPI {
  final Dio _dio;
  final String _baseUrl;
  final String _username;
  final String _password;
  String? _sessionCookie;

  QBitAPI._internal(
    this._dio,
    this._baseUrl,
    this._username,
    this._password,
  );

  factory QBitAPI.from(ZagProfile profile) {
    final baseUrl = Uri.encodeFull(profile.effectiveQbitHost());

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: profile.qbitHeaders,
        followRedirects: true,
        maxRedirects: 5,
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return QBitAPI._internal(
      dio,
      baseUrl,
      profile.qbitUser,
      profile.qbitPass,
    );
  }

  void logError(String text, Object error, StackTrace trace) =>
      ZagLogger().error('qBit: $text', error, trace);

  /// Authenticate and get session cookie
  Future<bool> login() async {
    try {
      final response = await _dio.post(
        '/api/v2/auth/login',
        data: 'username=$_username&password=$_password',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data == 'Ok.') {
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          for (final cookie in cookies) {
            if (cookie.startsWith('SID=')) {
              _sessionCookie = cookie.split(';')[0];
              break;
            }
          }
        }
        return true;
      }
      return false;
    } catch (error, stack) {
      logError('Failed to login', error, stack);
      return false;
    }
  }

  /// Ensure we have a valid session
  Future<void> _ensureSession() async {
    if (_sessionCookie == null) {
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
      if (_sessionCookie != null) 'Cookie': _sessionCookie,
    };
    return opts;
  }

  /// Test connection by getting version
  Future<String> testConnection() async {
    await _ensureSession();
    final response = await _dio.get(
      '/api/v2/app/version',
      options: _authOptions(),
    );
    return response.data.toString();
  }

  /// Get application version
  Future<String> getVersion() async {
    try {
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/app/version',
        options: _authOptions(),
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
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/transfer/info',
        options: _authOptions(),
      );
      return QBitStatusData.fromJson(response.data);
    } catch (error, stack) {
      logError('Failed to fetch transfer info', error, stack);
      rethrow;
    }
  }

  /// Get all torrents
  Future<List<QBitTorrentData>> getTorrents({String? filter, String? category}) async {
    try {
      await _ensureSession();
      final Map<String, dynamic> queryParams = {};
      if (filter != null) queryParams['filter'] = filter;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '/api/v2/torrents/info',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: _authOptions(),
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

  /// Get downloading torrents (queue)
  Future<List<QBitTorrentData>> getQueue() async {
    final torrents = await getTorrents();
    return torrents.where((t) => t.isDownloading || t.isPaused && !t.isCompleted).toList();
  }

  /// Get completed torrents (history/seeding)
  Future<List<QBitTorrentData>> getHistory() async {
    final torrents = await getTorrents();
    return torrents.where((t) => t.isCompleted || t.isSeeding).toList();
  }

  /// Get categories
  Future<List<QBitCategoryData>> getCategories() async {
    try {
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/torrents/categories',
        options: _authOptions(),
      );
      return QBitCategoryData.fromCategoriesJson(response.data);
    } catch (error, stack) {
      logError('Failed to fetch categories', error, stack);
      rethrow;
    }
  }

  /// Get torrent files
  Future<List<QBitFileData>> getTorrentFiles(String hash) async {
    try {
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/torrents/files',
        queryParameters: {'hash': hash},
        options: _authOptions(),
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
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/torrents/trackers',
        queryParameters: {'hash': hash},
        options: _authOptions(),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/pause',
        data: 'hashes=${hashes.join('|')}',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/resume',
        data: 'hashes=${hashes.join('|')}',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
  Future<bool> deleteTorrents(List<String> hashes, {bool deleteFiles = false}) async {
    try {
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/delete',
        data: 'hashes=${hashes.join('|')}&deleteFiles=$deleteFiles',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to delete torrents', error, stack);
      rethrow;
    }
  }

  /// Add torrent by magnet URL
  Future<bool> addTorrentUrl(String url, {String? category, bool? paused}) async {
    try {
      await _ensureSession();
      String data = 'urls=${Uri.encodeComponent(url)}';
      if (category != null && category.isNotEmpty) data += '&category=$category';
      if (paused != null) data += '&paused=$paused';

      await _dio.post(
        '/api/v2/torrents/add',
        data: data,
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to add torrent by URL', error, stack);
      rethrow;
    }
  }

  /// Add torrent by file
  Future<bool> addTorrentFile(List<int> data, String fileName, {String? category, bool? paused}) async {
    try {
      await _ensureSession();
      final formData = FormData.fromMap({
        'torrents': MultipartFile.fromBytes(data, filename: fileName),
        if (category != null && category.isNotEmpty) 'category': category,
        if (paused != null) 'paused': paused.toString(),
      });

      await _dio.post(
        '/api/v2/torrents/add',
        data: formData,
        options: _authOptions(),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/setCategory',
        data: 'hashes=${hashes.join('|')}&category=$category',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to set category', error, stack);
      rethrow;
    }
  }

  /// Set file priority
  Future<bool> setFilePriority(String hash, List<int> fileIds, int priority) async {
    try {
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/filePrio',
        data: 'hash=$hash&id=${fileIds.join('|')}&priority=$priority',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/recheck',
        data: 'hashes=$hash',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/reannounce',
        data: 'hashes=$hash',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/transfer/setDownloadLimit',
        data: 'limit=$limit',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/transfer/setUploadLimit',
        data: 'limit=$limit',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/transfer/toggleSpeedLimitsMode',
        options: _authOptions(),
      );
      return true;
    } catch (error, stack) {
      logError('Failed to toggle speed limits mode', error, stack);
      rethrow;
    }
  }

  /// Rename torrent
  Future<bool> renameTorrent(String hash, String name) async {
    try {
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/rename',
        data: 'hash=$hash&name=${Uri.encodeComponent(name)}',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      await _dio.post(
        '/api/v2/torrents/setLocation',
        data: 'hashes=${hashes.join('|')}&location=${Uri.encodeComponent(location)}',
        options: _authOptions(Options(
          contentType: Headers.formUrlEncodedContentType,
        )),
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
      await _ensureSession();
      final response = await _dio.get(
        '/api/v2/torrents/properties',
        queryParameters: {'hash': hash},
        options: _authOptions(),
      );
      return response.data;
    } catch (error, stack) {
      logError('Failed to fetch torrent properties', error, stack);
      rethrow;
    }
  }
}
