/// Dart library package to facilitate the communication to and from [Bazarr](https://bazarr.media)'s API:
/// A companion application to Sonarr and Radarr for downloading subtitles.
///
/// This library gives access to [bazarr_controllers], and is needed as the only entrypoint.
library bazarr;

import 'package:dio/dio.dart';
import 'package:zagreus/api/bazarr/controllers.dart';
import 'package:zagreus/database/tables/zagreus.dart';

/// The core class to handle all connections to Bazarr.
/// Gives you easy access to all implemented command handlers, initialized and ready to call.
///
/// [BazarrAPI] handles the creation of the initial [Dio] HTTP client & command handlers.
/// You can optionally use the factory `.from()` to define your own [Dio] HTTP client.
class BazarrAPI {
  /// Internal constructor
  BazarrAPI._internal({
    required this.httpClient,
    required this.system,
    required this.movie,
    required this.series,
    required this.episode,
    required this.provider,
    required this.language,
  });

  /// Create a new Bazarr API connection manager to connection to your instance.
  /// This default factory/constructor will create the [Dio] HTTP client for you given the parameters.
  ///
  /// Required Parameters:
  /// - `host`: String that contains the protocol (http:// or https://), the host itself, and the base URL (if applicable)
  /// - `apiKey`: The API key fetched from Bazarr's web interface
  ///
  /// Optional Parameters:
  /// - `headers`: Map that contains additional headers that should be attached to all requests
  /// - `followRedirects`: If the HTTP client should follow URL redirects
  /// - `maxRedirects`: The maximum amount of redirects the client should follow (does nothing if `followRedirects` is false)
  factory BazarrAPI({
    required String host,
    required String apiKey,
    Map<String, dynamic>? headers,
    bool followRedirects = true,
    int maxRedirects = 5,
    bool? slowServerMode,
  }) {
    final bool useSlowMode =
        slowServerMode ?? ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE.read();

    // Bazarr uses X-API-KEY header for authentication
    final Map<String, dynamic> finalHeaders = {
      'X-API-KEY': apiKey,
      ...?headers,
    };

    // Build the HTTP client
    Dio _dio = Dio(
      BaseOptions(
        baseUrl: host.endsWith('/') ? '${host}api/' : '$host/api/',
        headers: finalHeaders,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: useSlowMode ? 300 : 20),
        receiveTimeout: Duration(seconds: useSlowMode ? 300 : 30),
        sendTimeout: Duration(seconds: useSlowMode ? 300 : 20),
      ),
    );
    return BazarrAPI._internal(
      httpClient: _dio,
      system: BazarrControllerSystem(_dio),
      movie: BazarrControllerMovie(_dio),
      series: BazarrControllerSeries(_dio),
      episode: BazarrControllerEpisode(_dio),
      provider: BazarrControllerProvider(_dio),
      language: BazarrControllerLanguage(_dio),
    );
  }

  /// Create a new Bazarr API connection manager to connection to your instance.
  ///
  /// This factory allows you to define your own [Dio] HTTP client.
  /// Please ensure you set [BaseOptions] to include:
  /// - `baseUrl`: The URL to your Bazarr instance
  /// - `headers`: The key `X-API-KEY` with the value of your API key.
  factory BazarrAPI.from({
    required Dio client,
  }) {
    return BazarrAPI._internal(
      httpClient: client,
      system: BazarrControllerSystem(client),
      movie: BazarrControllerMovie(client),
      series: BazarrControllerSeries(client),
      episode: BazarrControllerEpisode(client),
      provider: BazarrControllerProvider(client),
      language: BazarrControllerLanguage(client),
    );
  }

  /// The [Dio] HTTP client built during initialization.
  final Dio httpClient;

  /// Controller for all system-related API calls.
  final BazarrControllerSystem system;

  /// Controller for all movie-related API calls.
  final BazarrControllerMovie movie;

  /// Controller for all series-related API calls.
  final BazarrControllerSeries series;

  /// Controller for all episode-related API calls.
  final BazarrControllerEpisode episode;

  /// Controller for all subtitle provider-related API calls.
  final BazarrControllerProvider provider;

  /// Controller for all language profile-related API calls.
  final BazarrControllerLanguage language;
}
