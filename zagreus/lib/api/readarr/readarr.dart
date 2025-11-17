/// Dart library package to facilitate the communication to and from [Readarr](https://readarr.com)'s API:
/// An ebook and audiobook collection manager for Usenet and BitTorrent users.
///
/// **Only v1 and newer releases of Readarr are supported with this library.**
///
/// This library gives access to all Readarr API endpoints and controllers.
library readarr;

// Imports
import 'package:dio/dio.dart';
import 'package:zagreus/api/readarr/controllers.dart';
import 'package:zagreus/database/tables/zagreus.dart';

/// The core class to handle all connections to Readarr.
/// Gives you easy access to all implemented command handlers, initialized and ready to call.
///
/// [ReadarrAPI] handles the creation of the initial [Dio] HTTP client & command handlers.
/// You can optionally use the factory `.from()` to define your own [Dio] HTTP client.
class ReadarrAPI {
  /// Internal constructor
  ReadarrAPI._internal({
    required this.httpClient,
    required this.author,
    required this.authorLookup,
    required this.book,
    required this.bookFile,
    required this.calendar,
    required this.command,
    required this.filesystem,
    required this.healthCheck,
    required this.history,
    required this.importList,
    required this.manualImport,
    required this.notification,
    required this.profile,
    required this.queue,
    required this.release,
    required this.rootFolder,
    required this.system,
    required this.tag,
  });

  /// Create a new Readarr API connection manager to connection to your instance.
  /// This default factory/constructor will create the [Dio] HTTP client for you given the parameters.
  ///
  /// Required Parameters:
  /// - `host`: String that contains the protocol (http:// or https://), the host itself, and the base URL (if applicable)
  /// - `apiKey`: The API key fetched from Readarr's web interface
  ///
  /// Optional Parameters:
  /// - `headers`: Map that contains additional headers that should be attached to all requests
  /// - `followRedirects`: If the HTTP client should follow URL redirects
  /// - `maxRedirects`: The maximum amount of redirects the client should follow (does nothing if `followRedirects` is false)
  factory ReadarrAPI({
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
    Dio _dio = Dio(
      BaseOptions(
        baseUrl: host.endsWith('/') ? '${host}api/v1/' : '$host/api/v1/',
        queryParameters: {
          'apikey': apiKey,
        },
        headers: headers,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        connectTimeout: Duration(seconds: useSlowMode ? 40 : 20),
        receiveTimeout: Duration(seconds: useSlowMode ? 60 : 30),
        sendTimeout: Duration(seconds: useSlowMode ? 40 : 20),
      ),
    );
    return ReadarrAPI._internal(
      httpClient: _dio,
      author: ReadarrControllerAuthor(_dio),
      authorLookup: ReadarrControllerAuthorLookup(_dio),
      book: ReadarrControllerBook(_dio),
      bookFile: ReadarrControllerBookFile(_dio),
      calendar: ReadarrControllerCalendar(_dio),
      command: ReadarrControllerCommand(_dio),
      filesystem: ReadarrControllerFilesystem(_dio),
      healthCheck: ReadarrControllerHealthCheck(_dio),
      history: ReadarrControllerHistory(_dio),
      importList: ReadarrControllerImportList(_dio),
      manualImport: ReadarrControllerManualImport(_dio),
      notification: ReadarrControllerNotification(_dio),
      profile: ReadarrControllerProfile(_dio),
      queue: ReadarrControllerQueue(_dio),
      release: ReadarrControllerRelease(_dio),
      rootFolder: ReadarrControllerRootFolder(_dio),
      system: ReadarrControllerSystem(_dio),
      tag: ReadarrControllerTag(_dio),
    );
  }

  /// Create a new Readarr API connection manager to connection to your instance.
  ///
  /// This factory allows you to define your own [Dio] HTTP client.
  /// Please ensure you set [BaseOptions] to include:
  /// - `baseUrl`: The URL to your Readarr instance
  /// - `queryParameters`: The key `apikey` with the value of your API key.
  ///
  /// Without these you will not be able to achieve a successful connection. See example below for bare minimum [Dio] configuration:
  /// ```dart
  /// Dio(
  ///     BaseOptions(
  ///         baseUrl: '<your instance URL>',
  ///         queryParameters: {
  ///             'apikey': '<your API key>',
  ///         },
  ///     ),
  /// );
  /// ```
  factory ReadarrAPI.from({
    required Dio client,
  }) {
    return ReadarrAPI._internal(
      httpClient: client,
      author: ReadarrControllerAuthor(client),
      authorLookup: ReadarrControllerAuthorLookup(client),
      book: ReadarrControllerBook(client),
      bookFile: ReadarrControllerBookFile(client),
      calendar: ReadarrControllerCalendar(client),
      command: ReadarrControllerCommand(client),
      filesystem: ReadarrControllerFilesystem(client),
      healthCheck: ReadarrControllerHealthCheck(client),
      history: ReadarrControllerHistory(client),
      importList: ReadarrControllerImportList(client),
      manualImport: ReadarrControllerManualImport(client),
      notification: ReadarrControllerNotification(client),
      profile: ReadarrControllerProfile(client),
      queue: ReadarrControllerQueue(client),
      release: ReadarrControllerRelease(client),
      rootFolder: ReadarrControllerRootFolder(client),
      system: ReadarrControllerSystem(client),
      tag: ReadarrControllerTag(client),
    );
  }

  /// The [Dio] HTTP client built during initialization.
  ///
  /// Making changes to the [Dio] client should propogate to the command handlers, but is not recommended.
  /// The recommended way to make changes to the HTTP client is to use the `.from()` factory to build your own [Dio] HTTP client.
  final Dio httpClient;

  /// Command handler for all author-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerAuthor author;

  /// Command handler for all author lookup-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerAuthorLookup authorLookup;

  /// Command handler for all book-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerBook book;

  /// Command handler for all book file-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerBookFile bookFile;

  /// Command handler for all calendar-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerCalendar calendar;

  /// Command handler for all command-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerCommand command;

  /// Command handler for all filesystem-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerFilesystem filesystem;

  /// Command handler for all health check-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerHealthCheck healthCheck;

  /// Command handler for all history-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerHistory history;

  /// Command handler for all import list-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerImportList importList;

  /// Command handler for all manual import-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerManualImport manualImport;

  /// Command handler for all notification-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerNotification notification;

  /// Command handler for all profile-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerProfile profile;

  /// Command handler for all queue-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerQueue queue;

  /// Command handler for all release-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerRelease release;

  /// Command handler for all root folder-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerRootFolder rootFolder;

  /// Command handler for all system-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerSystem system;

  /// Command handler for all tag-related API calls.
  ///
  /// _Check the documentation to see all API calls that fall under this category._
  final ReadarrControllerTag tag;
}
