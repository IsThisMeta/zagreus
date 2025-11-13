/// Dart library package to facilitate the communication to and from [Prowlarr](https://prowlarr.com)'s API:
/// An indexer manager/proxy for Usenet and BitTorrent users.
///
/// This library provides access to Prowlarr's search, category, and download capabilities.
library prowlarr;

import 'package:dio/dio.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/tables/zagreus.dart';

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
        connectTimeout: Duration(seconds: useSlowMode ? 120 : 60),
        receiveTimeout: Duration(seconds: useSlowMode ? 120 : 60),
        sendTimeout: Duration(seconds: useSlowMode ? 120 : 60),
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

  /// Perform a search across all configured indexers
  ///
  /// Parameters:
  /// - `query`: The search query string
  /// - `categoryId`: Optional category ID to filter results
  ///
  /// Returns a list of [ProwlarrItem] search results
  Future<List<ProwlarrItem>> performSearch(
    String query, {
    int? categoryId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'type': 'search',
        'limit': 4000,
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
}
