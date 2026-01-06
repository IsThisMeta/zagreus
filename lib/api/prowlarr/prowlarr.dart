/// Dart library package to facilitate the communication to and from [Prowlarr](https://prowlarr.com)'s API:
/// An indexer manager/proxy for Usenet and BitTorrent users.
///
/// This library provides access to Prowlarr's search, category, and download capabilities.
library prowlarr;

import 'package:dio/dio.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/system/logger.dart';

/// The core class to handle all connections to Prowlarr.
/// Provides search functionality, category management, and download capabilities.
///
/// [ProwlarrAPI] handles the creation of the initial [Dio] HTTP client.
class ProwlarrAPI {
  /// The HTTP client used for API requests
  final Dio httpClient;

  /// Internal constructor
  ProwlarrAPI._internal({
    required this.httpClient,
  });

  /// Create a new Prowlarr API connection manager to connect to your instance.
  /// This default factory/constructor will create the [Dio] HTTP client for you given the parameters.
  ///
  /// Required Parameters:
  /// - `host`: String that contains the protocol (http:// or https://), the host itself, and the base URL (if applicable)
  /// - `apiKey`: The API key fetched from Prowlarr's web interface
  ///
  /// Optional Parameters:
  /// - `headers`: Map that contains additional headers that should be attached to all requests
  /// - `followRedirects`: If the HTTP client should follow URL redirects
  /// - `maxRedirects`: The maximum amount of redirects the client should follow (does nothing if `followRedirects` is false)
  /// - `slowServerMode`: Enable extended timeouts for slow servers
  factory ProwlarrAPI({
    required String host,
    required String apiKey,
    Map<String, dynamic>? headers,
    bool followRedirects = true,
    int maxRedirects = 5,
    bool? slowServerMode,
  }) {
    final bool useSlowMode =
        slowServerMode ?? ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE.read();

    // Build the HTTP client
    Dio dio = Dio(
      BaseOptions(
        baseUrl: host.endsWith('/') ? '${host}api/v1/' : '$host/api/v1/',
        headers: {
          'X-Api-Key': apiKey,
          ...?headers,
        },
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: useSlowMode ? 300 : 60),
        receiveTimeout: Duration(seconds: useSlowMode ? 300 : 60),
        sendTimeout: Duration(seconds: useSlowMode ? 300 : 60),
      ),
    );

    // Add verbose logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (DioException e, handler) {
          _logError(e);
          handler.next(e);
        },
      ),
    );

    return ProwlarrAPI._internal(
      httpClient: dio,
    );
  }

  /// Create a Prowlarr API instance from an existing [Dio] client
  factory ProwlarrAPI.from({
    required Dio client,
  }) {
    return ProwlarrAPI._internal(
      httpClient: client,
    );
  }

  /// Get all available categories from the Prowlarr instance
  ///
  /// Returns a list of [ProwlarrCategory] objects representing the category tree
  Future<List<ProwlarrCategory>> getCategories() async {
    try {
      Response response = await httpClient.get('indexer/categories');
      return (response.data as List)
          .map((json) => ProwlarrCategory.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Default limit for search results
  /// Note: Prowlarr's limit parameter is known to not work server-side
  static const int defaultLimit = 4000;

  /// Perform a search across all configured indexers
  ///
  /// Parameters:
  /// - `query`: The search query string
  /// - `categoryId`: Optional category ID to filter results
  /// - `limit`: Maximum number of results (default: 100)
  ///
  /// Returns a list of [ProwlarrItem] search results
  Future<List<ProwlarrItem>> performSearch(
    String query, {
    int? categoryId,
    int limit = defaultLimit,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'type': 'search',
        'limit': limit,
        'query': query,
      };

      if (categoryId != null) {
        queryParams['categories'] = categoryId;
      }

      Response response = await httpClient.get(
        'search',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => ProwlarrItem.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Download a release to a configured download client
  ///
  /// Parameters:
  /// - `guid`: The unique identifier of the release
  /// - `indexerId`: The ID of the indexer that provided the release
  ///
  /// Returns `true` if the download was successfully sent to the client
  Future<bool> downloadToClient({
    required String guid,
    required int indexerId,
  }) async {
    try {
      final postData = DownloadClientPostData(
        guid: guid,
        indexerId: indexerId,
      );

      Response response = await httpClient.post(
        'search',
        data: postData.toJson(),
        queryParameters: {
          'type': 'search',
          'limit': 4000,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Log outgoing request details
  static void _logRequest(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    final msg = StringBuffer('Prowlarr request: $method $uri');

    // Log headers (excluding sensitive API key)
    final headers = Map<String, dynamic>.from(options.headers);
    headers.remove('X-Api-Key');
    if (headers.isNotEmpty) {
      msg.write(' headers=$headers');
    }

    // Log timeouts
    msg.write(' connectTimeout=${options.connectTimeout?.inSeconds}s');
    msg.write(' receiveTimeout=${options.receiveTimeout?.inSeconds}s');

    ZagLogger().debug(msg.toString());
  }

  /// Log successful response details
  static void _logResponse(Response response) {
    final status = response.statusCode;
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;

    final msg = StringBuffer('Prowlarr response: $method $uri');
    msg.write(' status=$status');

    // Log response size if available
    final data = response.data;
    if (data is List) {
      msg.write(' items=${data.length}');
    } else if (data is Map) {
      msg.write(' keys=${data.keys.length}');
    }

    ZagLogger().debug(msg.toString());
  }

  /// Log error details with verbose information
  static void _logError(DioException e) {
    final status = e.response?.statusCode;
    final reason = e.response?.statusMessage;
    final uri = e.requestOptions.uri;
    final method = e.requestOptions.method;
    final errorType = e.type.name;

    final msg = StringBuffer('Prowlarr request failed: $method $uri');
    msg.write(' type=$errorType');
    if (status != null) msg.write(' status=$status');
    if (reason?.isNotEmpty ?? false) msg.write(' reason=$reason');
    if (e.message?.isNotEmpty ?? false) msg.write(' message=${e.message}');

    // Add connection-specific error details
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        msg.write(' (connection timed out after ${e.requestOptions.connectTimeout?.inSeconds}s)');
        break;
      case DioExceptionType.receiveTimeout:
        msg.write(' (receive timed out after ${e.requestOptions.receiveTimeout?.inSeconds}s)');
        break;
      case DioExceptionType.sendTimeout:
        msg.write(' (send timed out after ${e.requestOptions.sendTimeout?.inSeconds}s)');
        break;
      case DioExceptionType.connectionError:
        msg.write(' (could not connect to server - check host URL and network)');
        break;
      case DioExceptionType.badCertificate:
        msg.write(' (SSL certificate error - server certificate invalid)');
        break;
      case DioExceptionType.badResponse:
        msg.write(' (server returned unexpected response)');
        break;
      case DioExceptionType.cancel:
        msg.write(' (request was cancelled)');
        break;
      case DioExceptionType.unknown:
        if (e.error != null) msg.write(' innerError=${e.error}');
        break;
    }

    ZagLogger().error(msg.toString(), e, e.stackTrace);

    // Log response body for additional context
    final data = e.response?.data;
    if (data != null) {
      final preview = _safeDataPreview(data);
      ZagLogger().debug('Prowlarr error response body: $preview');
    }
  }

  /// Safely preview response data with truncation
  static String _safeDataPreview(dynamic data, {int limit = 500}) {
    final text = data.toString();
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }
}
